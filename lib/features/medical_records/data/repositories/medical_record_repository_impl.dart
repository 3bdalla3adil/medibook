import '../../../../core/error/result.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/repositories/medical_record_repository.dart';
import '../datasources/medical_record_remote_data_source.dart';

class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  const MedicalRecordRepositoryImpl(this._remote);
  final MedicalRecordRemoteDataSource _remote;

  @override
  Future<Result<List<MedicalRecordEntry>>> getEntries(String patientId) async {
    final result = await guard(() => _remote.fetchEntries(patientId));
    return result.map((items) => items.map((e) => e.toDomain()).toList(growable: false));
  }
}
