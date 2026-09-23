import '../../domain/entities/medical_service.dart';

class MedicalServiceDto {
  const MedicalServiceDto(this.json);
  final Map<String, dynamic> json;

  factory MedicalServiceDto.fromJson(Map<String, dynamic> json) => MedicalServiceDto(json);

  MedicalService toDomain() => MedicalService(
        id: json['id'].toString(),
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        currency: json['currency']?.toString() ?? '',
        clinicId: json['clinic_id']?.toString() ?? '',
        isTelehealthAvailable: json['is_telehealth_available'] as bool? ?? false,
      );
}
