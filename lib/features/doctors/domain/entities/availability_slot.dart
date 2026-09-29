import 'package:equatable/equatable.dart';

/// A bookable slot returned by the server. The client treats this as
/// read-only truth and never modifies it locally.
class AvailabilitySlot extends Equatable {
  const AvailabilitySlot({
    required this.startsAt,
    required this.duration,
    required this.isBookable,
    this.reason,
  });

  /// Absolute UTC. Convert to clinic timezone for display.
  final DateTime startsAt;
  final Duration duration;

  /// False if the slot exists on the schedule but is unbookable —
  /// already taken, blocked by the doctor, too close to now.
  final bool isBookable;

  final String? reason;

  DateTime get endsAt => startsAt.add(duration);

  @override
  List<Object?> get props => [startsAt, isBookable];
}
