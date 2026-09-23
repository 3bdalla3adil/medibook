import '../../../../core/error/result.dart';
import '../../domain/entities/patient_summary.dart';
import '../../domain/repositories/patient_directory_repository.dart';
import '../datasources/patient_directory_remote_data_source.dart';

class PatientDirectoryRepositoryImpl implements PatientDirectoryRepository {
  const PatientDirectoryRepositoryImpl(this._remote);
  final PatientDirectoryRemoteDataSource _remote;

  @override
  Future<Result<List<PatientSummary>>> getPatients() async {
    final result = await guard(() => _remote.fetchPatients());
    return result.map((items) => items.map((e) => e.toDomain()).toList(growable: false));
  }
}
