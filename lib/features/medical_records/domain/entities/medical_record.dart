import 'package:equatable/equatable.dart';

enum RecordEntrySource { patientReported, clinicianEntered, labImport }

class MedicalRecordEntry extends Equatable {
  const MedicalRecordEntry({
    required this.id,
    required this.createdBy,
    required this.createdAt,
    required this.recordedBy,
    required this.recordedAt,
    required this.source,
    required this.title,
    required this.body,
    this.supersedesId,
  });

  final String id;
  final String createdBy;
  final DateTime createdAt;
  final String recordedBy;
  final DateTime recordedAt;
  final RecordEntrySource source;
  final String title;
  final String body;
  final String? supersedesId;

  @override
  List<Object?> get props => [
        id, createdBy, createdAt, recordedBy, recordedAt,
        source, title, body, supersedesId,
      ];
}
