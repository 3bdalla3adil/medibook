import '../../../../core/demo/demo_seed.dart';
import '../models/consultation_dto.dart';
import 'consultation_remote_data_source.dart';

class DemoConsultationRemoteDataSource implements ConsultationRemoteDataSource {
  const DemoConsultationRemoteDataSource();

  @override
  Future<List<ConsultationDto>> fetchConsultations() async => DemoSeed.consultations();

  @override
  Future<ConsultationDto?> fetchConsultation(String id) async {
    for (final item in DemoSeed.consultations()) {
      if (item.json['id'].toString() == id) return item;
    }
    return null;
  }

  @override
  Future<ConsultationDto> start(String appointmentId) async => DemoSeed.consultations().first;

  @override
  Future<ConsultationDto> complete(String id) async => DemoSeed.consultations().first;
}
