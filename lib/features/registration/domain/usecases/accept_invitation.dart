import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../repositories/registration_repository.dart';

class AcceptInvitation {
  const AcceptInvitation(this._repository);
  final RegistrationRepository _repository;
  Future<Result<AuthUser>> call({required String token, required String password, required String displayName}) => _repository.acceptInvitation(token: token, password: password, displayName: displayName);
}
