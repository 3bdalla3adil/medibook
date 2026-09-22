import '../../../../core/storage/boxes.dart';
import '../../../../core/storage/local_store.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_status.dart';
import '../models/appointment_dto.dart';

abstract interface class AppointmentLocalDataSource {
  Future<List<Appointment>> getAppointments();
  Future<Appointment?> getAppointment(String id);
  Future<void> saveAll(List<AppointmentDto> dtos);
  Future<void> save(Appointment appointment);
  Future<void> delete(String id);
  Future<void> clear();
}

class HiveAppointmentLocalDataSource implements AppointmentLocalDataSource {
  HiveAppointmentLocalDataSource(
    this._store, {
    this.retention = const Duration(days: 90),
  });

  final LocalStore _store;
  final Duration retention;

  @override
  Future<List<Appointment>> getAppointments() async {
    final raw = await _store.readAll<Map<String, dynamic>>(Boxes.appointments);

    return raw
        .map(AppointmentDto.fromJson)
        .map((dto) => dto.toDomain().copyWith(syncStatus: SyncStatus.cached))
        .toList(growable: false)
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Future<Appointment?> getAppointment(String id) async {
    final raw = await _store.read<Map<String, dynamic>>(Boxes.appointments, id);
    return raw == null
        ? null
        : AppointmentDto.fromJson(raw).toDomain().copyWith(syncStatus: SyncStatus.cached);
  }

  @override
  Future<void> saveAll(List<AppointmentDto> dtos) async {
    await _store.putAll(
      Boxes.appointments,
      {for (final d in dtos) d.json['id'].toString(): d.json},
    );
  }

  @override
  Future<void> save(Appointment appointment) async {
    await _store.write(Boxes.appointments, appointment.id, _toJson(appointment));
  }

  @override
  Future<void> delete(String id) => _store.delete(Boxes.appointments, id);

  @override
  Future<void> clear() => _store.clearBox(Boxes.appointments);

  Map<String, dynamic> _toJson(Appointment a) => {
        'id': a.id,
        'clinic_id': a.clinicId,
        'clinic_name': a.clinicName,
        'patient_id': a.patientId,
        'doctor_id': a.doctorId,
        'doctor_name': a.doctorName,
        'doctor_avatar_url': a.doctorAvatarUrl,
        'service_id': a.serviceId,
        'service_name': a.serviceName,
        'starts_at': a.startsAt.toUtc().toIso8601String(),
        'duration_minutes': a.duration.inMinutes,
        'status': a.status.toWire(),
        'is_telehealth': a.isTelehealth,
        'room_label': a.roomLabel,
        'cancellation_reason': a.cancellationReason,
        'cancelled_at': a.cancelledAt?.toUtc().toIso8601String(),
        'notes': a.notes,
        'created_at': a.createdAt.toUtc().toIso8601String(),
        'updated_at': a.updatedAt.toUtc().toIso8601String(),
        'version': a.version,
      };
}
