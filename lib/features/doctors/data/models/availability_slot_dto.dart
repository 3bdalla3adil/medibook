import '../../domain/entities/availability_slot.dart';

class AvailabilitySlotDto {
  const AvailabilitySlotDto(this.json);
  final Map<String, dynamic> json;

  static AvailabilitySlotDto fromJson(Map<String, dynamic> json) =>
      AvailabilitySlotDto(json);

  AvailabilitySlot toDomain() => AvailabilitySlot(
        startsAt: DateTime.parse(json['starts_at'] as String).toUtc(),
        duration: Duration(minutes: (json['duration_minutes'] as num).toInt()),
        isBookable: json['is_bookable'] as bool? ?? false,
        reason: json['reason'] as String?,
      );
}
