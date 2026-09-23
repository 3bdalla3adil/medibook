import '../../../../core/error/result.dart';
import '../entities/patient_summary.dart';

abstract interface class PatientDirectoryRepository {
  Future<Result<List<PatientSummary>>> getPatients();
}
