import '../../../../core/demo/demo_seed.dart';
import '../models/clinic_dto.dart';
import 'clinic_remote_data_source.dart';

class DemoClinicRemoteDataSource implements ClinicRemoteDataSource {
  const DemoClinicRemoteDataSource();

  @override
  Future<List<ClinicDto>> fetchClinics({bool activeOnly = true}) async =>
      DemoSeed.clinics()
          .where((item) => !activeOnly || item.json['is_active'] == true)
          .toList(growable: false);

  @override
  Future<ClinicDto?> fetchClinic(String id) async {
    for (final item in DemoSeed.clinics()) {
      if (item.json['id'].toString() == id) return item;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchServices(String id) async =>
      DemoSeed.services().map((item) => item.json).toList(growable: false);
}
