import 'package:equatable/equatable.dart';

class BookingOption extends Equatable {
  const BookingOption({required this.id, required this.name, this.description});
  final String id;
  final String name;
  final String? description;
  @override
  List<Object?> get props => [id, name, description];
}
