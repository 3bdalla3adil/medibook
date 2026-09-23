import '../../../../core/demo/demo_seed.dart';
import 'patient_remote_data_source.dart';
import '../models/patient_dto.dart';

class DemoPatientRemoteDataSource implements PatientRemoteDataSource {
  const DemoPatientRemoteDataSource();

  @override
  Future<PatientDto?> fetchCurrent() async => DemoSeed.patient();

  @override
  Future<PatientDto?> fetchById(String id) async =>
      id == DemoSeed.patientId ? DemoSeed.patient() : null;
}
