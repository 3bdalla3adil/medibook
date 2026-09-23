import 'package:equatable/equatable.dart';

class Clinic extends Equatable {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.timezone,
    required this.phone,
    required this.organizationId,
    this.openingHours = const {},
    this.services = const [],
    this.isActive = true,
  });

  final String id;
  final Map<String, String> name;
  final String address;
  final String timezone;
  final String phone;
  final Map<String, String> openingHours;
  final List<String> services;
  final String organizationId;
  final bool isActive;

  String localizedName(String locale) {
    if (name.containsKey(locale)) return name[locale]!;
    if (name.containsKey('en')) return name['en']!;
    return name.isEmpty ? id : name.values.first;
  }

  @override
  List<Object?> get props => [
        id, name, address, timezone, phone, organizationId,
        openingHours, services, isActive,
      ];
}
