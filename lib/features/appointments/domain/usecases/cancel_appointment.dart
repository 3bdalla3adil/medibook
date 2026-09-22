import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/appointment.dart';
import '../entities/appointment_status.dart';
import '../repositories/appointment_repository.dart';

class CancelAppointmentUseCase {
  const CancelAppointmentUseCase(this._repository);
  final AppointmentRepository _repository;

  Future<Result<Appointment>> call(String id, {String? reason}) async {
    final current = await _repository.getAppointment(id);
    switch (current) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: final appointment):
        if (appointment == null) return const Err(NotFoundFailure());
        if (!appointment.status.canTransitionTo(AppointmentStatus.cancelled)) {
          return const Err(ConflictFailure());
        }
    }
    return _repository.cancelAppointment(id, reason: reason);
  }
}
