import '../../../../core/error/result.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_data_source.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  const DoctorRepositoryImpl(this._remote);
  final DoctorRemoteDataSource _remote;

  @override
  Future<Result<List<Doctor>>> getDoctors({String? clinicId, String? serviceId}) async {
    final result = await guard(() => _remote.fetchDoctors(
          clinicId: clinicId,
          serviceId: serviceId,
        ));
    return result.map((items) => items.map((e) => e.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<Doctor?>> getDoctor(String id) async {
    final result = await guard(() => _remote.fetchDoctor(id));
    return result.map((e) => e?.toDomain());
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getAvailability({
    required String doctorId,
    required DateTime from,
    required DateTime to,
    String? clinicId,
    String? serviceId,
  }) => guard(() => _remote.fetchAvailability(
        doctorId: doctorId,
        from: from,
        to: to,
        clinicId: clinicId,
        serviceId: serviceId,
      ));
}
