import '../../../../core/error/result.dart';
import '../../domain/entities/medical_service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_data_source.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  const ServiceRepositoryImpl(this._remote);
  final ServiceRemoteDataSource _remote;

  @override
  Future<Result<List<MedicalService>>> getServices({String? clinicId}) async {
    final result = await guard(() => _remote.fetchServices(clinicId: clinicId));
    return result.map((items) => items.map((e) => e.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<MedicalService?>> getService(String id) async {
    final result = await guard(() => _remote.fetchService(id));
    return result.map((e) => e?.toDomain());
  }
}
