import 'package:equatable/equatable.dart';

class BookingSlot extends Equatable {
  const BookingSlot({required this.startsAt, required this.duration});
  final DateTime startsAt;
  final Duration duration;
  DateTime get endsAt => startsAt.add(duration);
  @override
  List<Object?> get props => [startsAt, duration];
}
