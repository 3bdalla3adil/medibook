import '../../../../core/demo/demo_seed.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/repositories/patient_repository.dart';

/// In-memory patient repository for the demo environment.
///
/// It deliberately does not use LocalStore/Hive/secure storage. A new app
/// process therefore starts with the deterministic seed again.
class DemoPatientRepository implements PatientRepository {
  const DemoPatientRepository();

  @override
  Future<Result<PatientProfile?>> getCurrentProfile() async =>
      Ok(DemoSeed.patient().toDomain());

  @override
  Future<Result<PatientProfile?>> getPatient(String id) async =>
      Ok(id == DemoSeed.patientId ? DemoSeed.patient().toDomain() : null);
}
