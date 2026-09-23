import 'package:equatable/equatable.dart';

class MedicalService extends Equatable {
  const MedicalService({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.price,
    required this.currency,
    required this.clinicId,
    required this.isTelehealthAvailable,
  });

  final String id;
  final String name;
  final String description;
  final int durationMinutes;
  final double price;
  final String currency;
  final String clinicId;
  final bool isTelehealthAvailable;

  @override
  List<Object?> get props => [
        id, name, description, durationMinutes, price,
        currency, clinicId, isTelehealthAvailable,
      ];
}
