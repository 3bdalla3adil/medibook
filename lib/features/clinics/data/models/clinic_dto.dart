import '../../domain/entities/clinic.dart';

class ClinicDto {
  const ClinicDto(this.json);
  final Map<String, dynamic> json;

  factory ClinicDto.fromJson(Map<String, dynamic> json) => ClinicDto(json);

  Clinic toDomain() {
    final rawName = json['name'];
    final name = rawName is Map
        ? rawName.map((key, value) => MapEntry(key.toString(), value.toString()))
        : {'en': rawName?.toString() ?? ''};
    final rawHours = json['opening_hours'];
    final openingHours = rawHours is Map
        ? rawHours.map((key, value) => MapEntry(key.toString(), value.toString()))
        : <String, String>{};
    final rawServices = json['services'];
    return Clinic(
      id: json['id'].toString(),
      name: name,
      address: json['address']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? 'UTC',
      phone: json['phone']?.toString() ?? '',
      openingHours: openingHours,
      services: rawServices is List
          ? rawServices.map((e) => e.toString()).toList()
          : const [],
      organizationId: json['organization_id']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
