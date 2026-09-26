import '../../domain/entities/medical_record.dart';

class MedicalRecordEntryDto {
  const MedicalRecordEntryDto(this.json);
  final Map<String, dynamic> json;

  factory MedicalRecordEntryDto.fromJson(Map<String, dynamic> json) =>
      MedicalRecordEntryDto(json);

  MedicalRecordEntry toDomain() {
    final createdAtText =
        json['created_at']?.toString() ?? json['recorded_at']?.toString();
    final recordedAtText =
        json['recorded_at']?.toString() ?? json['created_at']?.toString();

    return MedicalRecordEntry(
      id: json['id'].toString(),
      createdBy: json['created_by']?.toString() ??
          json['recorded_by']?.toString() ??
          json['patient_id']?.toString() ??
          '',
      createdAt: DateTime.parse(createdAtText!).toUtc(),
      recordedBy: json['recorded_by']?.toString() ??
          json['created_by']?.toString() ??
          json['patient_id']?.toString() ??
          '',
      recordedAt: DateTime.parse(recordedAtText!).toUtc(),
      source: switch (json['source']?.toString() ?? json['entry_type']?.toString()) {
        'patient_reported' => RecordEntrySource.patientReported,
        'lab_import' || 'lab' => RecordEntrySource.labImport,
        _ => RecordEntrySource.clinicianEntered,
      },
      title: json['title']?.toString() ??
          json['entry_type']?.toString() ??
          'Medical record',
      body: json['body']?.toString() ?? json['summary']?.toString() ?? '',
      supersedesId: json['supersedes_id']?.toString(),
    );
  }
}
