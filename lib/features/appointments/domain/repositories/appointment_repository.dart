import '../../../../core/error/result.dart';
import '../entities/appointment.dart';

abstract interface class AppointmentRepository {
  Future<Result<List<Appointment>>> getAppointments({
    DateTime? from,
    DateTime? to,
    bool forceRefresh = false,
  });

  Future<Result<Appointment?>> getAppointment(String id);
  Future<Result<Appointment?>> getUpcomingAppointment();
  Future<Result<Appointment>> createAppointment(Appointment appointment);
  Future<Result<Appointment>> updateAppointment(Appointment appointment);
  Future<Result<Appointment>> cancelAppointment(String id, {String? reason});
  Future<Result<Appointment>> rescheduleAppointment(String id, DateTime newStart);

  Stream<List<Appointment>> watchAppointments();
}
