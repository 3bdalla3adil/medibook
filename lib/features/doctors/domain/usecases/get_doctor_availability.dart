import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/availability_slot.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorAvailabilityUseCase {
  const GetDoctorAvailabilityUseCase(this._repository);
  final DoctorRepository _repository;

  Future<Result<List<AvailabilitySlot>>> call({
    required String doctorId,
    required String clinicId,
    required String serviceId,
    required DateTime from,
    required DateTime to,
  }) {
    if (doctorId.isEmpty || clinicId.isEmpty || serviceId.isEmpty) {
      return Future.value(const Err(ValidationFailure()));
    }
    if (!to.isAfter(from)) {
      return Future.value(const Err(ValidationFailure()));
    }
    if (to.difference(from).inDays > 60) {
      // Guard against a UI bug requesting a year of slots.
      return Future.value(const Err(ValidationFailure()));
    }
    return _repository.getAvailability(
      doctorId: doctorId,
      clinicId: clinicId,
      serviceId: serviceId,
      from: from,
      to: to,
    );
  }
}
