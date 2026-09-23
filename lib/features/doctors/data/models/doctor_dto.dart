import '../../domain/entities/doctor.dart';

class DoctorDto {
  const DoctorDto(this.json);
  final Map<String, dynamic> json;

  factory DoctorDto.fromJson(Map<String, dynamic> json) => DoctorDto(json);

  Doctor toDomain() => Doctor(
        id: json['id'].toString(),
        displayName: json['display_name']?.toString() ?? '',
        specialization: json['specialization']?.toString() ?? '',
        licenseNumber: json['license_number']?.toString() ?? '',
        bio: json['bio']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString(),
        clinicIds: _strings(json['clinic_ids']),
        serviceIds: _strings(json['service_ids']),
        languages: _strings(json['languages']),
      );

  static List<String> _strings(Object? value) =>
      value is List ? value.map((e) => e.toString()).toList(growable: false) : const [];
}
