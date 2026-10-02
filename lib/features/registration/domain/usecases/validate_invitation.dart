import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/invitation.dart';
import '../repositories/registration_repository.dart';

class ValidateInvitation {
  const ValidateInvitation(this._repository);
  final RegistrationRepository _repository;
  Future<Result<Invitation>> call(String token) async {
    final result = await _repository.validateInvitation(token);
    return switch (result) {
      Ok<Invitation>(:final value) => value.isExpired(DateTime.now()) || value.isUsed
          ? const Err<Invitation>(ConflictFailure(code: 'invitation_unavailable'))
          : Ok<Invitation>(value),
      Err<Invitation>(:final failure) => Err<Invitation>(failure),
    };
  }
}
