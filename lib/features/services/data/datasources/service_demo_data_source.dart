import '../../../../core/demo/demo_seed.dart';
import '../models/medical_service_dto.dart';
import 'service_remote_data_source.dart';

class DemoServiceRemoteDataSource implements ServiceRemoteDataSource {
  const DemoServiceRemoteDataSource();

  @override
  Future<List<MedicalServiceDto>> fetchServices({String? clinicId}) async =>
      DemoSeed.services()
          .where((item) => clinicId == null || item.json['clinic_id'].toString() == clinicId)
          .toList(growable: false);

  @override
  Future<MedicalServiceDto?> fetchService(String id) async {
    for (final item in DemoSeed.services()) {
      if (item.json['id'].toString() == id) return item;
    }
    return null;
  }
}
