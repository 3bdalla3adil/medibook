import '../../../../core/demo/demo_seed.dart';
import '../models/medical_record_entry_dto.dart';
import 'medical_record_remote_data_source.dart';

class DemoMedicalRecordRemoteDataSource implements MedicalRecordRemoteDataSource {
  const DemoMedicalRecordRemoteDataSource();

  @override
  Future<List<MedicalRecordEntryDto>> fetchEntries(String patientId) async =>
      patientId == DemoSeed.patientId ? DemoSeed.records() : const [];
}
