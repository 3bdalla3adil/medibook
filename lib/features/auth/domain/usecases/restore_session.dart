import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<Session>> call() => _repository.restoreSession();
}
