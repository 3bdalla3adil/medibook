import '../../../../core/error/result.dart';
import '../entities/doctor_assignment.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorAssignmentsUseCase {
  const GetDoctorAssignmentsUseCase(this._repository);
  final DoctorRepository _repository;

  Future<Result<List<DoctorAssignment>>> call(String doctorId) =>
      _repository.getAssignments(doctorId);
}
