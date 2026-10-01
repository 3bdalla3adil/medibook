import '../../../../core/error/result.dart';
import '../../domain/entities/triage_vitals.dart';
import '../../domain/repositories/triage_repository.dart';

class DemoTriageRepository implements TriageRepository {
  final Map<String,TriageVitals> _store={};
  @override
  Future<Result<TriageVitals?>> getForAppointment(String appointmentId) async => Ok(_store[appointmentId]);
  @override
  Future<Result<TriageVitals>> save(String appointmentId,TriageVitals vitals) async {
    _store[appointmentId]=vitals;
    return Ok(vitals);
  }
}
