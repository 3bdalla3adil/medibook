import '../../../../core/error/result.dart';
import '../entities/medical_record.dart';

abstract interface class MedicalRecordRepository {
  Future<Result<List<MedicalRecordEntry>>> getEntries(String patientId);
}
