import '../../domain/entities/medical_record.dart';

class MedicalRecordEntryDto {
  const MedicalRecordEntryDto(this.json);
  final Map<String, dynamic> json;

  factory MedicalRecordEntryDto.fromJson(Map<String, dynamic> json) =>
      MedicalRecordEntryDto(json);

  MedicalRecordEntry toDomain() => MedicalRecordEntry(
        id: json['id'].toString(),
        createdBy: json['created_by'].toString(),
        createdAt: DateTime.parse(json['created_at'].toString()).toUtc(),
        recordedBy: json['recorded_by'].toString(),
        recordedAt: DateTime.parse(json['recorded_at'].toString()).toUtc(),
        source: switch (json['source']?.toString()) {
          'patient_reported' => RecordEntrySource.patientReported,
          'lab_import' => RecordEntrySource.labImport,
          _ => RecordEntrySource.clinicianEntered,
        },
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        supersedesId: json['supersedes_id']?.toString(),
      );
}
