import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  const Doctor({
    required this.id,
    required this.displayName,
    this.specialization,
    this.licenseNumber,
    this.avatarUrl,
    this.bio,
    this.languages = const {},
    this.clinicIds = const {},
    this.serviceIds = const {},
  });

  final String id;
  final String displayName;
  final String? specialization;
  final String? licenseNumber;
  final String? avatarUrl;
  final String? bio;
  final Set<String> languages;
  final Set<String> clinicIds;
  final Set<String> serviceIds;

  @override
  List<Object?> get props => [id, displayName, specialization, licenseNumber, avatarUrl, bio, clinicIds, serviceIds, languages];
}
