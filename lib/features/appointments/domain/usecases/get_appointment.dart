import '../../../../core/error/result.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentUseCase {
  const GetAppointmentUseCase(this._repository);
  final AppointmentRepository _repository;

  Future<Result<Appointment?>> call(String id) => _repository.getAppointment(id);
}
