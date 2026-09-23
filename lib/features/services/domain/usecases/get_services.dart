import '../../../../core/error/result.dart';
import '../entities/medical_service.dart';
import '../repositories/service_repository.dart';

class GetServicesUseCase {
  const GetServicesUseCase(this._repository);
  final ServiceRepository _repository;

  Future<Result<List<MedicalService>>> call({String? clinicId}) =>
      _repository.getServices(clinicId: clinicId);
}
