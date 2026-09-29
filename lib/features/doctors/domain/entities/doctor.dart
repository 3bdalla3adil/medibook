import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  const Doctor({
    required this.id,
    required this.displayName,
    this.specialization,
    this.avatarUrl,
    this.bio,
    this.languages = const {},
  });

  final String id;
  final String displayName;
  final String? specialization;
  final String? avatarUrl;
  final String? bio;
  final Set<String> languages;

  @override
  List<Object?> get props => [id, displayName, specialization];
}
