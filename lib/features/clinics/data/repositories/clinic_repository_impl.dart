import '../../../../core/error/result.dart';
import '../../domain/entities/clinic.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../datasources/clinic_remote_data_source.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  const ClinicRepositoryImpl(this._remote);
  final ClinicRemoteDataSource _remote;

  @override
  Future<Result<List<Clinic>>> getClinics({bool activeOnly = true}) async {
    final result = await guard(() => _remote.fetchClinics(activeOnly: activeOnly));
    return result.map((items) => items.map((item) => item.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<Clinic?>> getClinic(String id) async {
    final result = await guard(() => _remote.fetchClinic(id));
    return result.map((item) => item?.toDomain());
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getClinicServices(String id) =>
      guard(() => _remote.fetchServices(id));
}
