import '../../../../core/demo/demo_seed.dart';
import 'patient_directory_remote_data_source.dart';

class DemoPatientDirectoryRemoteDataSource implements PatientDirectoryRemoteDataSource {
  const DemoPatientDirectoryRemoteDataSource();

  @override
  Future<List<PatientSummaryDto>> fetchPatients() async => DemoSeed.patients();
}
