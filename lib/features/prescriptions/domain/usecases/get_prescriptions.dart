import '../../../../core/error/result.dart';
import '../entities/prescription.dart';
import '../repositories/prescription_repository.dart';

class GetPrescriptionsUseCase {
  const GetPrescriptionsUseCase(this._repository);
  final PrescriptionRepository _repository;
  Future<Result<List<Prescription>>> call() => _repository.getPrescriptions();
}
