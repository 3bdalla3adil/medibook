import 'package:equatable/equatable.dart';

enum ConsultationStatus { draft, inProgress, completed, signed }

class Consultation extends Equatable {
  const Consultation({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.startedAt,
    required this.status,
    this.note,
    this.diagnosis,
  });

  final String id;
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final DateTime startedAt;
  final ConsultationStatus status;
  final String? note;
  final String? diagnosis;

  @override
  List<Object?> get props => [
        id, appointmentId, patientId, doctorId, startedAt,
        status, note, diagnosis,
      ];
}
