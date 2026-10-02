import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/registration_draft.dart';
import '../repositories/registration_repository.dart';

class RegisterPatient {
  const RegisterPatient(this._repository);
  final RegistrationRepository _repository;
  Future<Result<void>> call(RegistrationDraft draft) {
    if (draft.email.trim().isEmpty || draft.password.length < 8 || draft.displayName.trim().isEmpty) {
      return Future.value(const Err<void>(ValidationFailure(fieldErrors: {'registration': ['invalid']})));
    }
    return _repository.registerPatient(draft);
  }
}
