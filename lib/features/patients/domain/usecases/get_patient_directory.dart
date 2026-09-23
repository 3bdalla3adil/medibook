import '../../../../core/error/result.dart';
import '../entities/patient_summary.dart';
import '../repositories/patient_directory_repository.dart';

class GetPatientDirectoryUseCase {
  const GetPatientDirectoryUseCase(this._repository);
  final PatientDirectoryRepository _repository;

  Future<Result<List<PatientSummary>>> call() => _repository.getPatients();
}
