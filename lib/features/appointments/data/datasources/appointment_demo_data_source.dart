import '../../../../core/demo/demo_seed.dart';
import '../models/appointment_dto.dart';
import 'appointment_remote_data_source.dart';

class DemoAppointmentRemoteDataSource implements AppointmentRemoteDataSource {
  const DemoAppointmentRemoteDataSource();

  @override
  Future<List<AppointmentDto>> fetchAppointments({DateTime? from, DateTime? to}) {
    final items = DemoSeed.appointments();
    final filtered = items.where((dto) {
      final startsAt = DateTime.parse(dto.json['starts_at'] as String).toUtc();
      return (from == null || !startsAt.isBefore(from.toUtc())) &&
          (to == null || startsAt.isBefore(to.toUtc()));
    }).toList(growable: false);
    return Future.value(filtered);
  }

  @override
  Future<AppointmentDto?> fetchAppointment(String id) async =>
      DemoSeed.appointments().where((e) => e.json['id'].toString() == id).firstOrNull;

  @override
  Future<AppointmentDto> create(Map<String, dynamic> body, {required String idempotencyKey}) async {
    throw UnsupportedError('Demo appointment creation is intentionally handled by the booking demo repository.');
  }

  @override
  Future<AppointmentDto> update(String id, Map<String, dynamic> body, {int? version}) async {
    throw UnsupportedError('Demo appointment update is intentionally not enabled.');
  }

  @override
  Future<AppointmentDto> cancel(String id, {String? reason}) async {
    final existing = await fetchAppointment(id);
    if (existing == null) throw StateError('Demo appointment not found');
    final json = Map<String, dynamic>.from(existing.json)
      ..['status'] = 'cancelled'
      ..['cancellation_reason'] = reason;
    return AppointmentDto(json);
  }

  @override
  Future<AppointmentDto> reschedule(String id, DateTime newStart) async {
    final existing = await fetchAppointment(id);
    if (existing == null) throw StateError('Demo appointment not found');
    final json = Map<String, dynamic>.from(existing.json)
      ..['starts_at'] = newStart.toUtc().toIso8601String();
    return AppointmentDto(json);
  }
}
