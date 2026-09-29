import '../../domain/entities/doctor_assignment.dart';

class DoctorAssignmentDto {
  const DoctorAssignmentDto(this.json);
  final Map<String, dynamic> json;

  static DoctorAssignmentDto fromJson(Map<String, dynamic> json) =>
      DoctorAssignmentDto(json);

  DoctorAssignment toDomain() {
    final weekly = <int, List<TimeRange>>{};
    final rawWeekly = json['weekly_availability'] as Map<String, dynamic>? ?? {};
    for (final entry in rawWeekly.entries) {
      final weekday = int.parse(entry.key);
      final ranges = (entry.value as List)
          .cast<Map<String, dynamic>>()
          .map((r) => TimeRange(
                start: (r['start'] as num).toInt(),
                end: (r['end'] as num).toInt(),
              ))
          .toList();
      weekly[weekday] = ranges;
    }

    final exceptions = ((json['exceptions'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map((e) => AvailabilityException(
              date: DateTime.parse(e['date'] as String),
              isAvailable: e['is_available'] as bool? ?? false,
              ranges: ((e['ranges'] as List?) ?? const [])
                  .cast<Map<String, dynamic>>()
                  .map((r) => TimeRange(
                        start: (r['start'] as num).toInt(),
                        end: (r['end'] as num).toInt(),
                      ))
                  .toList(),
              reason: e['reason'] as String?,
            ))
        .toList();

    return DoctorAssignment(
      id: json['id'].toString(),
      doctorId: json['doctor_id'].toString(),
      clinicId: json['clinic_id'].toString(),
      serviceIds: ((json['service_ids'] as List?) ?? const [])
          .map((e) => e.toString())
          .toSet(),
      weeklyAvailability: weekly,
      exceptions: exceptions,
      isActive: json['is_active'] as bool? ?? true,
      roomLabel: json['room_label'] as String?,
    );
  }
}
