import '../../../../core/error/result.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentsUseCase {
  const GetAppointmentsUseCase(this._repository);
  final AppointmentRepository _repository;

  Future<Result<List<Appointment>>> call({
    DateTime? from,
    DateTime? to,
    bool forceRefresh = false,
  }) =>
      _repository.getAppointments(from: from, to: to, forceRefresh: forceRefresh);
}
