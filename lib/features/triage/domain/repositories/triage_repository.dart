import '../../../../core/error/result.dart';
import '../entities/triage_vitals.dart';

abstract interface class TriageRepository {
  Future<Result<TriageVitals?>> getForAppointment(String appointmentId);
  Future<Result<TriageVitals>> save(String appointmentId, TriageVitals vitals);
}
