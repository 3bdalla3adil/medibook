import '../../domain/entities/prescription.dart';

class PrescriptionDto {
  const PrescriptionDto(this.json);
  final Map<String, dynamic> json;

  factory PrescriptionDto.fromJson(Map<String, dynamic> json) => PrescriptionDto(json);

  Prescription toDomain() => Prescription(
        id: json['id'].toString(),
        consultationId: json['consultation_id'].toString(),
        patientId: json['patient_id'].toString(),
        prescriberId: json['prescriber_id'].toString(),
        issuedAt: DateTime.parse(json['issued_at'].toString()).toUtc(),
        status: switch (json['status']?.toString()) {
          'draft' => PrescriptionStatus.draft,
          'cancelled' => PrescriptionStatus.cancelled,
          'expired' => PrescriptionStatus.expired,
          _ => PrescriptionStatus.issued,
        },
        items: _items(json['items']),
      );

  static List<PrescriptionItem> _items(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((item) {
      return PrescriptionItem(
        medicationId: item['medication_id'].toString(),
        medicationName: item['medication_name']?.toString() ?? '',
        dose: item['dose']?.toString() ?? '',
        route: item['route']?.toString() ?? '',
        frequency: item['frequency']?.toString() ?? '',
        duration: item['duration']?.toString() ?? '',
        quantity: (item['quantity'] as num?)?.toInt() ?? 0,
        instructions: item['instructions']?.toString() ?? '',
      );
    }).toList(growable: false);
  }
}
