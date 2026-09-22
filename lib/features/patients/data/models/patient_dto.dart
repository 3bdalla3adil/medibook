import '../../domain/entities/patient_profile.dart';

class PatientDto {
  const PatientDto(this.json);
  final Map<String, dynamic> json;

  static PatientDto fromJson(Map<String, dynamic> json) => PatientDto(json);

  PatientProfile toDomain() => PatientProfile(
        id: json['id'].toString(),
        displayName: json['display_name'] as String? ?? '',
        organizationId: json['organization_id']?.toString() ?? '',
        avatarUrl: json['avatar_url'] as String?,
        preferredLocale: json['preferred_locale'] as String?,
        dateOfBirth: json['date_of_birth'] == null
            ? null
            : DateTime.parse(json['date_of_birth'] as String),
      );
}
