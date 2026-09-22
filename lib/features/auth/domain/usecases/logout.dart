import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call({bool revokeOnServer = true}) =>
      _repository.logout(revokeOnServer: revokeOnServer);
}
