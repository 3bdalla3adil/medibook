import '../../../../core/error/result.dart';
import '../entities/doctor.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorUseCase {
  const GetDoctorUseCase(this._repository);

  final DoctorRepository _repository;

  Future<Result<Doctor?>> call(String id) => _repository.getDoctor(id);
}
