import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<Session>> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    final normalizedName = displayName.trim();
    final normalizedEmail = email.trim();

    if (normalizedName.length < 2 ||
        normalizedEmail.isEmpty ||
        !normalizedEmail.contains('@') ||
        password.length < 8) {
      return Future.value(const Err(ValidationFailure()));
    }

    return _repository.register(
      email: normalizedEmail,
      password: password,
      displayName: normalizedName,
    );
  }
}
