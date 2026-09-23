import '../../domain/entities/consultation.dart';

class ConsultationDto {
  const ConsultationDto(this.json);
  final Map<String, dynamic> json;

  factory ConsultationDto.fromJson(Map<String, dynamic> json) => ConsultationDto(json);

  Consultation toDomain() => Consultation(
        id: json['id'].toString(),
        appointmentId: json['appointment_id'].toString(),
        patientId: json['patient_id'].toString(),
        doctorId: json['doctor_id'].toString(),
        startedAt: DateTime.parse(json['started_at'].toString()).toUtc(),
        status: switch (json['status']?.toString()) {
          'draft' => ConsultationStatus.draft,
          'in_progress' => ConsultationStatus.inProgress,
          'completed' => ConsultationStatus.completed,
          _ => ConsultationStatus.signed,
        },
        note: json['note']?.toString(),
        diagnosis: json['diagnosis']?.toString(),
      );
}
