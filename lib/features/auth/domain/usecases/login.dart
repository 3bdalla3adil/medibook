import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<Session>> call({required String email, required String password}) {
    if (email.trim().isEmpty || !email.contains('@')) {
      return Future.value(const Err(ValidationFailure()));
    }
    if (password.isEmpty) {
      return Future.value(const Err(ValidationFailure()));
    }
    return _repository.login(email: email.trim(), password: password);
  }
}
