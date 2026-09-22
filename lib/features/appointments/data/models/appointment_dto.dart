import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_status.dart';

class AppointmentDto {
  const AppointmentDto(this.json);
  final Map<String, dynamic> json;

  static AppointmentDto fromJson(Map<String, dynamic> json) => AppointmentDto(json);

  Appointment toDomain() {
    return Appointment(
      id: json['id'].toString(),
      clinicId: json['clinic_id'].toString(),
      clinicName: json['clinic_name'] as String?,
      patientId: json['patient_id'].toString(),
      doctorId: json['doctor_id'].toString(),
      doctorName: json['doctor_name'] as String? ?? '',
      doctorAvatarUrl: json['doctor_avatar_url'] as String?,
      serviceId: json['service_id'].toString(),
      serviceName: json['service_name'] as String? ?? '',
      startsAt: DateTime.parse(json['starts_at'] as String).toUtc(),
      duration: Duration(minutes: (json['duration_minutes'] as num).toInt()),
      status: AppointmentStatus.fromWire(json['status'] as String),
      isTelehealth: json['is_telehealth'] as bool? ?? false,
      roomLabel: json['room_label'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String).toUtc(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      version: (json['version'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => json;
}
