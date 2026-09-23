import '../../../../core/error/result.dart';
import '../../domain/entities/consultation.dart';
import '../../domain/repositories/consultation_repository.dart';
import '../datasources/consultation_remote_data_source.dart';

class ConsultationRepositoryImpl implements ConsultationRepository {
  const ConsultationRepositoryImpl(this._remote);
  final ConsultationRemoteDataSource _remote;

  @override
  Future<Result<List<Consultation>>> getConsultations() async {
    final result = await guard(_remote.fetchConsultations);
    return result.map((items) => items.map((e) => e.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<Consultation?>> getConsultation(String id) async {
    final result = await guard(() => _remote.fetchConsultation(id));
    return result.map((e) => e?.toDomain());
  }

  @override
  Future<Result<Consultation>> startConsultation(String appointmentId) async {
    final result = await guard(() => _remote.start(appointmentId));
    return result.map((e) => e.toDomain());
  }

  @override
  Future<Result<Consultation>> completeConsultation(String id) async {
    final result = await guard(() => _remote.complete(id));
    return result.map((e) => e.toDomain());
  }
}
