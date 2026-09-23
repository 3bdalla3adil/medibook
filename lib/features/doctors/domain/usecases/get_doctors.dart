import '../../../../core/error/result.dart';
import '../entities/doctor.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorsUseCase {
  const GetDoctorsUseCase(this._repository);
  final DoctorRepository _repository;

  Future<Result<List<Doctor>>> call({String? clinicId, String? serviceId}) =>
      _repository.getDoctors(clinicId: clinicId, serviceId: serviceId);
}
