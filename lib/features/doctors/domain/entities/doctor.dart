import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  const Doctor({
    required this.id,
    required this.displayName,
    required this.specialization,
    required this.licenseNumber,
    required this.bio,
    required this.avatarUrl,
    required this.clinicIds,
    required this.serviceIds,
    required this.languages,
  });

  final String id;
  final String displayName;
  final String specialization;
  final String licenseNumber;
  final String bio;
  final String? avatarUrl;
  final List<String> clinicIds;
  final List<String> serviceIds;
  final List<String> languages;

  @override
  List<Object?> get props => [
        id, displayName, specialization, licenseNumber, bio,
        avatarUrl, clinicIds, serviceIds, languages,
      ];
}
