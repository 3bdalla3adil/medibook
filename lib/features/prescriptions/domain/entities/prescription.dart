import 'package:equatable/equatable.dart';

enum PrescriptionStatus { draft, issued, cancelled, expired }

class PrescriptionItem extends Equatable {
  const PrescriptionItem({
    required this.medicationId,
    required this.medicationName,
    required this.dose,
    required this.route,
    required this.frequency,
    required this.duration,
    required this.quantity,
    required this.instructions,
  });

  final String medicationId;
  final String medicationName;
  final String dose;
  final String route;
  final String frequency;
  final String duration;
  final int quantity;
  final String instructions;

  @override
  List<Object?> get props => [
        medicationId, medicationName, dose, route, frequency,
        duration, quantity, instructions,
      ];
}

class Prescription extends Equatable {
  const Prescription({
    required this.id,
    required this.consultationId,
    required this.patientId,
    required this.prescriberId,
    required this.issuedAt,
    required this.status,
    required this.items,
  });

  final String id;
  final String consultationId;
  final String patientId;
  final String prescriberId;
  final DateTime issuedAt;
  final PrescriptionStatus status;
  final List<PrescriptionItem> items;

  @override
  List<Object?> get props => [
        id, consultationId, patientId, prescriberId,
        issuedAt, status, items,
      ];
}
