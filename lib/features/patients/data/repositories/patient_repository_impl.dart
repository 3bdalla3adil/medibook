import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/boxes.dart';
import '../../../../core/storage/local_store.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_data_source.dart';
import '../models/patient_dto.dart';

class PatientRepositoryImpl implements PatientRepository {
  PatientRepositoryImpl({
    required PatientRemoteDataSource remote,
    required LocalStore local,
  })  : _remote = remote,
        _local = local;

  final PatientRemoteDataSource _remote;
  final LocalStore _local;

  @override
  Future<Result<PatientProfile?>> getCurrentProfile() async {
    final cached = await _local.read<Map<String, dynamic>>(Boxes.patients, 'me');
    final cachedProfile =
        cached == null ? null : PatientDto.fromJson(cached).toDomain();

    final remote = await guard(() => _remote.fetchCurrent());

    switch (remote) {
      case Ok(value: final dto):
        if (dto == null) return Ok(cachedProfile);
        await _local.write(Boxes.patients, 'me', dto.json);
        return Ok(dto.toDomain());
      case Err(:final failure):
        if (failure is NetworkFailure || failure is TimeoutFailure) {
          return Ok(cachedProfile);
        }
        return Err(failure);
    }
  }

  @override
  Future<Result<PatientProfile?>> getPatient(String id) async {
    final result = await guard(() => _remote.fetchById(id));
    return result.map((dto) => dto?.toDomain());
  }
}
