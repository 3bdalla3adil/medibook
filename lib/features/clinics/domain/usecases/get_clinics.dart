import '../../../../core/error/result.dart';
import '../entities/clinic.dart';
import '../repositories/clinic_repository.dart';

class GetClinicsUseCase {
  const GetClinicsUseCase(this._repository);
  final ClinicRepository _repository;

  Future<Result<List<Clinic>>> call({bool activeOnly = true}) =>
      _repository.getClinics(activeOnly: activeOnly);
}
