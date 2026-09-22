import 'package:equatable/equatable.dart';

class PatientProfile extends Equatable {
  const PatientProfile({
    required this.id,
    required this.displayName,
    required this.organizationId,
    this.avatarUrl,
    this.preferredLocale,
    this.dateOfBirth,
  });

  final String id;
  final String displayName;
  final String organizationId;
  final String? avatarUrl;
  final String? preferredLocale;
  final DateTime? dateOfBirth;

  @override
  List<Object?> get props => [id, displayName, organizationId, avatarUrl];
}
