import 'dart:async';

import '../../../../core/demo/demo_seed.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../core/utils/clock.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_status.dart';
import '../../domain/repositories/appointment_repository.dart';

class DemoAppointmentRepository implements AppointmentRepository {
  DemoAppointmentRepository(this._clock)
      : _items = DemoSeed.appointments()
            .map((e) => e.toDomain())
            .toList(growable: true);

  final Clock _clock;
  final List<Appointment> _items;
  final _changes = StreamController<List<Appointment>>.broadcast();

  @override
  Stream<List<Appointment>> watchAppointments() => _changes.stream;

  @override
  Future<Result<List<Appointment>>> getAppointments({
    DateTime? from,
    DateTime? to,
    bool forceRefresh = false,
  }) async {
    final result = _items.where((item) {
      return (from == null || !item.startsAt.isBefore(from.toUtc())) &&
          (to == null || item.startsAt.isBefore(to.toUtc()));
    }).toList(growable: false);
    return Ok(result);
  }

  @override
  Future<Result<Appointment?>> getAppointment(String id) async =>
      Ok(_find(id));

  @override
  Future<Result<Appointment?>> getUpcomingAppointment() async {
    final now = _clock.now();
    final upcoming = _items.where((item) => item.isUpcoming(now)).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return Ok(upcoming.isEmpty ? null : upcoming.first);
  }

  @override
  Future<Result<Appointment>> createAppointment(Appointment appointment) async {
    final created = appointment.copyWith(
      syncStatus: SyncStatus.synced,
      updatedAt: _clock.now(),
    );
    _items.removeWhere((item) => item.id == created.id);
    _items.add(created);
    _emit();
    return Ok(created);
  }

  @override
  Future<Result<Appointment>> updateAppointment(Appointment appointment) async {
    if (_find(appointment.id) == null) return const Err(NotFoundFailure());
    final updated = appointment.copyWith(
      syncStatus: SyncStatus.synced,
      updatedAt: _clock.now(),
    );
    _items[_items.indexWhere((item) => item.id == appointment.id)] = updated;
    _emit();
    return Ok(updated);
  }

  @override
  Future<Result<Appointment>> cancelAppointment(String id, {String? reason}) async {
    final existing = _find(id);
    if (existing == null) return const Err(NotFoundFailure());
    final updated = existing.copyWith(
      status: AppointmentStatus.cancelled,
      cancellationReason: reason,
      cancelledAt: _clock.now(),
      syncStatus: SyncStatus.synced,
      updatedAt: _clock.now(),
    );
    _items[_items.indexWhere((item) => item.id == id)] = updated;
    _emit();
    return Ok(updated);
  }

  @override
  Future<Result<Appointment>> rescheduleAppointment(String id, DateTime newStart) async {
    final existing = _find(id);
    if (existing == null) return const Err(NotFoundFailure());
    final updated = existing.copyWith(
      startsAt: newStart.toUtc(),
      status: AppointmentStatus.scheduled,
      syncStatus: SyncStatus.synced,
      updatedAt: _clock.now(),
    );
    _items[_items.indexWhere((item) => item.id == id)] = updated;
    _emit();
    return Ok(updated);
  }

  Appointment? _find(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _emit() => _changes.add(List.unmodifiable(_items));
}
