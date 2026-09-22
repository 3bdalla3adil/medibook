import '../../../../core/error/result.dart';
import '../entities/patient_profile.dart';

abstract interface class PatientRepository {
  Future<Result<PatientProfile?>> getCurrentProfile();
  Future<Result<PatientProfile?>> getPatient(String id);
}
