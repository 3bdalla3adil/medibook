import 'package:equatable/equatable.dart';

class RegistrationDraft extends Equatable {
  const RegistrationDraft({required this.email, required this.password, required this.displayName});
  final String email;
  final String password;
  final String displayName;
  @override List<Object?> get props => [email, password, displayName];
}
