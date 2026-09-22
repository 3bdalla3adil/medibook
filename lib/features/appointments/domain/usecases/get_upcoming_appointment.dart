import '../../../../core/error/result.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetUpcomingAppointmentUseCase {
  const GetUpcomingAppointmentUseCase(this._repository);
  final AppointmentRepository _repository;

  Future<Result<Appointment?>> call() => _repository.getUpcomingAppointment();
}
