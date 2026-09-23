import '../../../../core/error/result.dart';
import '../entities/medical_record.dart';
import '../repositories/medical_record_repository.dart';

class GetMedicalRecordUseCase {
  const GetMedicalRecordUseCase(this._repository);
  final MedicalRecordRepository _repository;

  Future<Result<List<MedicalRecordEntry>>> call(String patientId) =>
      _repository.getEntries(patientId);
}
