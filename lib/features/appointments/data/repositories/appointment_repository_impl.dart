import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/sync/outbox.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../core/utils/clock.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_status.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_local_data_source.dart';
import '../datasources/appointment_remote_data_source.dart';

class AppointmentRepositoryImpl implements AppointmentRepository, OutboxHandler {
  AppointmentRepositoryImpl({
    required AppointmentRemoteDataSource remote,
    required AppointmentLocalDataSource local,
    required SyncEngine sync,
    required NetworkInfo networkInfo,
    required Clock clock,
    Uuid? uuid,
  })  : _remote = remote,
        _local = local,
        _sync = sync,
        _network = networkInfo,
        _clock = clock,
        _uuid = uuid ?? const Uuid() {
    _sync.register(this);
  }

  final AppointmentRemoteDataSource _remote;
  final AppointmentLocalDataSource _local;
  final SyncEngine _sync;
  final NetworkInfo _network;
  final Clock _clock;
  final Uuid _uuid;
  final _changes = StreamController<List<Appointment>>.broadcast();

  @override
  String get entityType => 'appointment';

  @override
  Stream<List<Appointment>> watchAppointments() => _changes.stream;

  @override
  Future<Result<List<Appointment>>> getAppointments({
    DateTime? from,
    DateTime? to,
    bool forceRefresh = false,
  }) async {
    final online = await _network.isOnline();

    if (!online) {
      final cached = await _local.getAppointments();
      return Ok(_filter(cached, from, to));
    }

    final cached = await _local.getAppointments();

    if (!forceRefresh && cached.isNotEmpty) {
      unawaited(_revalidate(from: from, to: to));
      return Ok(_filter(cached, from, to));
    }

    final remote = await guard(() => _remote.fetchAppointments(from: from, to: to));
    return remote.mapAsync((dtos) async {
      await _local.saveAll(dtos);
      final merged = await _local.getAppointments();
      _emit(merged);
      return _filter(merged, from, to);
    });
  }

  Future<void> _revalidate({DateTime? from, DateTime? to}) async {
    final result = await guard(() => _remote.fetchAppointments(from: from, to: to));
    if (result case Ok(value: final dtos)) {
      await _local.saveAll(dtos);
      _emit(await _local.getAppointments());
    }
  }

  @override
  Future<Result<Appointment?>> getAppointment(String id) async {
    final cached = await _local.getAppointment(id);

    if (!await _network.isOnline()) return Ok(cached);

    final remote = await guard(() => _remote.fetchAppointment(id));
    return remote.mapAsync((dto) async {
      if (dto == null) {
        await _local.delete(id);
        _emit(await _local.getAppointments());
        return null;
      }
      final appointment = dto.toDomain();
      await _local.save(appointment);
      return appointment;
    });
  }

  @override
  Future<Result<Appointment?>> getUpcomingAppointment() async {
    final result = await getAppointments(from: _clock.now());
    return result.map((list) {
      final upcoming = list.where((a) => a.status.isActive).toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      return upcoming.isEmpty ? null : upcoming.first;
    });
  }

  @override
  Future<Result<Appointment>> createAppointment(Appointment appointment) async {
    final now = _clock.now();
    final optimistic = appointment.copyWith(
      syncStatus: SyncStatus.pending,
      updatedAt: now,
    );

    await _local.save(optimistic);
    _emit(await _local.getAppointments());

    if (!await _network.isOnline()) {
      await _enqueue(OutboxOp.create, optimistic);
      return Ok(optimistic);
    }

    final result = await guard(() => _remote.create(
          _toWire(optimistic),
          idempotencyKey: _uuid.v4(),
        ),);

    switch (result) {
      case Ok(value: final dto):
        final confirmed = dto.toDomain();
        await _local.save(confirmed);
        _emit(await _local.getAppointments());
        return Ok(confirmed);

      case Err(:final failure):
        await _local.delete(optimistic.id);
        _emit(await _local.getAppointments());
        return Err(failure);
    }
  }

  @override
  Future<Result<Appointment>> updateAppointment(Appointment appointment) async {
    await _local.save(appointment.copyWith(syncStatus: SyncStatus.pending));
    _emit(await _local.getAppointments());

    if (!await _network.isOnline()) {
      await _enqueue(OutboxOp.update, appointment);
      return Ok(appointment.copyWith(syncStatus: SyncStatus.pending));
    }

    final result = await guard(() => _remote.update(
          appointment.id,
          _toWire(appointment),
          version: appointment.version,
        ));

    return result.mapAsync((dto) async {
      final confirmed = dto.toDomain();
      await _local.save(confirmed);
      _emit(await _local.getAppointments());
      return confirmed;
    });
  }

  @override
  Future<Result<Appointment>> cancelAppointment(String id, {String? reason}) async {
    final existing = await _local.getAppointment(id);
    if (existing == null) return const Err(NotFoundFailure());

    final optimistic = existing.copyWith(
      status: AppointmentStatus.cancelled,
      cancellationReason: reason,
      cancelledAt: _clock.now(),
      syncStatus: SyncStatus.pending,
    );
    await _local.save(optimistic);
    _emit(await _local.getAppointments());

    if (!await _network.isOnline()) {
      await _enqueue(OutboxOp.update, optimistic);
      return Ok(optimistic);
    }

    final result = await guard(() => _remote.cancel(id, reason: reason));
    return result.mapAsync((dto) async {
      final confirmed = dto.toDomain();
      await _local.save(confirmed);
      _emit(await _local.getAppointments());
      return confirmed;
    });
  }

  @override
  Future<Result<Appointment>> rescheduleAppointment(String id, DateTime newStart) async {
    final existing = await _local.getAppointment(id);
    if (existing == null) return const Err(NotFoundFailure());

    final optimistic = existing.copyWith(
      startsAt: newStart.toUtc(),
      status: AppointmentStatus.scheduled,
      syncStatus: SyncStatus.pending,
    );
    await _local.save(optimistic);
    _emit(await _local.getAppointments());

    if (!await _network.isOnline()) {
      await _enqueue(OutboxOp.update, optimistic);
      return Ok(optimistic);
    }

    final result = await guard(() => _remote.reschedule(id, newStart));
    return result.mapAsync((dto) async {
      final confirmed = dto.toDomain();
      await _local.save(confirmed);
      _emit(await _local.getAppointments());
      return confirmed;
    });
  }

  @override
  Future<void> push(OutboxEntry entry) async {
    switch (entry.op) {
      case OutboxOp.create:
        final dto = await _remote.create(entry.payload, idempotencyKey: entry.id);
        await _local.save(dto.toDomain());
      case OutboxOp.update:
        final dto = await _remote.update(
          entry.entityId,
          entry.payload,
          version: entry.localVersion,
        );
        await _local.save(dto.toDomain());
      case OutboxOp.delete:
        await _remote.cancel(entry.entityId);
        await _local.delete(entry.entityId);
    }
    _emit(await _local.getAppointments());
  }

  Future<void> _enqueue(
    OutboxOp op,
    Appointment appointment, {
    OutboxOp? overrideOp,
  }) async {
    final now = _clock.now();
    await _sync.enqueue(
      OutboxEntry(
        id: _uuid.v4(),
        entityType: entityType,
        entityId: appointment.id,
        op: overrideOp ?? op,
        payload: _toWire(appointment),
        createdAt: now,
        localVersion: appointment.version,
      ),
    );
  }

  Map<String, dynamic> _toWire(Appointment a) => {
        'id': a.id,
        'clinic_id': a.clinicId,
        'patient_id': a.patientId,
        'doctor_id': a.doctorId,
        'service_id': a.serviceId,
        'starts_at': a.startsAt.toUtc().toIso8601String(),
        'duration_minutes': a.duration.inMinutes,
        'is_telehealth': a.isTelehealth,
        'notes': a.notes,
        'version': a.version,
      };

  List<Appointment> _filter(List<Appointment> source, DateTime? from, DateTime? to) =>
      source.where((a) {
        if (from != null && a.endsAt.isBefore(from)) return false;
        if (to != null && a.startsAt.isAfter(to)) return false;
        return true;
      }).toList(growable: false);

  void _emit(List<Appointment> appointments) {
    if (!_changes.isClosed) _changes.add(appointments);
  }
}
