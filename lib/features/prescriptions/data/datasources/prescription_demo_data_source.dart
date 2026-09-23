import '../../../../core/demo/demo_seed.dart';
import '../models/prescription_dto.dart';
import 'prescription_remote_data_source.dart';

class DemoPrescriptionRemoteDataSource implements PrescriptionRemoteDataSource {
  const DemoPrescriptionRemoteDataSource();

  @override
  Future<List<PrescriptionDto>> fetchPrescriptions() async => DemoSeed.prescriptions();
}
