import '../../../../core/error/result.dart';
import '../entities/patient_profile.dart';
import '../repositories/patient_repository.dart';

class GetPatientProfileUseCase {
  const GetPatientProfileUseCase(this._repository);
  final PatientRepository _repository;

  Future<Result<PatientProfile?>> call() => _repository.getCurrentProfile();
}
