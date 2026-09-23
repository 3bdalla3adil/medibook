import 'package:equatable/equatable.dart';

class PatientSummary extends Equatable {
  const PatientSummary({
    required this.id,
    required this.displayName,
    required this.dateOfBirth,
    required this.lastVisit,
    required this.primaryClinicId,
  });

  final String id;
  final String displayName;
  final DateTime? dateOfBirth;
  final DateTime? lastVisit;
  final String? primaryClinicId;

  @override
  List<Object?> get props => [id, displayName, dateOfBirth, lastVisit, primaryClinicId];
}
