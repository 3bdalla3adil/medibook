import 'package:equatable/equatable.dart';

/// A doctor's assignment to a clinic, with the services they provide
/// there and when they are available.
///
/// This is the join entity between Doctor, Clinic, Service, and time.
/// A doctor has one assignment per clinic they work at, and may provide
/// different services at different clinics.
class DoctorAssignment extends Equatable {
  const DoctorAssignment({
    required this.id,
    required this.doctorId,
    required this.clinicId,
    required this.serviceIds,
    required this.weeklyAvailability,
    this.exceptions = const [],
    this.isActive = true,
    this.roomLabel,
  });

  final String id;
  final String doctorId;
  final String clinicId;

  /// Services this doctor provides at THIS clinic. A doctor may
  /// provide different services at different clinics.
  final Set<String> serviceIds;

  /// Recurring weekly schedule. Keyed by ISO weekday (1=Mon, 7=Sun).
  /// Each day has a list of time ranges — usually one, but a doctor
  /// may work a morning and evening shift with a break between.
  final Map<int, List<TimeRange>> weeklyAvailability;

  /// Date-specific overrides (holidays, extra shifts, cancellations).
  /// Overrides always win over weeklyAvailability for that date.
  final List<AvailabilityException> exceptions;

  final bool isActive;
  final String? roomLabel;

  bool providesService(String serviceId) => serviceIds.contains(serviceId);

  @override
  List<Object?> get props => [id, doctorId, clinicId, serviceIds, isActive];
}

/// A time range on a specific weekday, in the clinic's local timezone.
class TimeRange extends Equatable {
  const TimeRange({required this.start, required this.end});

  /// Minutes since midnight, local to the clinic. 540 = 09:00, 1020 = 17:00.
  /// Using minutes rather than DateTime avoids the timezone trap: a
  /// weekly schedule is timezone-agnostic. Only actual bookings convert
  /// to absolute UTC.
  final int start;
  final int end;

  bool contains(int minuteOfDay) =>
      minuteOfDay >= start && minuteOfDay < end;

  int get durationMinutes => end - start;

  @override
  List<Object?> get props => [start, end];
}

/// A single-date override. Either removes availability (holiday) or
/// adds it (weekend shift).
class AvailabilityException extends Equatable {
  const AvailabilityException({
    required this.date,
    required this.isAvailable,
    this.ranges = const [],
    this.reason,
  });

  /// ISO date in the clinic's timezone, not UTC. A doctor's "off on
  /// December 25" is a date in the clinic's calendar, not a UTC instant.
  final DateTime date;

  /// false = unavailable all day (holiday, conference).
  /// true = available at [ranges] even if weeklyAvailability says no.
  final bool isAvailable;

  final List<TimeRange> ranges;
  final String? reason;

  @override
  List<Object?> get props => [date, isAvailable];
}
