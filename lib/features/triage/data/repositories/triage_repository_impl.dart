import '../../../../core/error/result.dart';
import '../../domain/entities/triage_vitals.dart';
import '../../domain/repositories/triage_repository.dart';
import '../datasources/triage_remote_data_source.dart';

class TriageRepositoryImpl implements TriageRepository {
  const TriageRepositoryImpl(this._remote);
  final TriageRemoteDataSource _remote;
  @override
  Future<Result<TriageVitals?>> getForAppointment(String appointmentId) async =>
      guard(() async => (await _remote.fetch(appointmentId))?.data);
  @override
  Future<Result<TriageVitals>> save(String appointmentId,TriageVitals vitals) async =>
      guard(() async => (await _remote.save(appointmentId,TriageVitalsDto(data:vitals))).data);
}
