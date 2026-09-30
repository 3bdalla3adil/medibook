import '../../../../core/demo/demo_seed.dart';
import '../models/doctor_assignment_dto.dart';
import '../models/doctor_dto.dart';
import '../models/availability_slot_dto.dart';
import 'doctor_remote_data_source.dart';

class DemoDoctorRemoteDataSource implements DoctorRemoteDataSource {
  const DemoDoctorRemoteDataSource();

  @override
  Future<List<DoctorDto>> fetchDoctors({String? clinicId, String? serviceId}) async =>
      DemoSeed.doctors()
          .where((item) {
            final clinics = item.json['clinic_ids'] as List? ?? const [];
            final services = item.json['service_ids'] as List? ?? const [];
            return (clinicId == null || clinics.map((e) => e.toString()).contains(clinicId)) &&
                (serviceId == null || services.map((e) => e.toString()).contains(serviceId));
          })
          .toList(growable: false);

  @override
  Future<DoctorDto?> fetchDoctor(String id) async {
    for (final item in DemoSeed.doctors()) {
      if (item.json['id'].toString() == id) return item;
    }
    return null;
  }

  @override
  @override
  Future<List<DoctorAssignmentDto>> fetchAssignments(String doctorId) async => [
        DoctorAssignmentDto({
          'id': 'demo-assignment-001',
          'doctor_id': doctorId,
          'clinic_id': DemoSeed.clinicId,
          'service_ids': [DemoSeed.serviceId],
          'weekly_availability': {
            '1': [{'start': 540, 'end': 780}],
            '2': [{'start': 540, 'end': 780}],
            '3': [{'start': 540, 'end': 780}],
            '4': [{'start': 540, 'end': 780}],
            '5': [{'start': 540, 'end': 720}],
          },
          'exceptions': const [],
          'is_active': true,
          'room_label': 'Demo Room 101',
        }),
      ];

  @override
  Future<List<AvailabilitySlotDto>> fetchAvailability({
    required String doctorId,
    required String clinicId,
    required String serviceId,
    required DateTime from,
    required DateTime to,
  }) async {
    final start = DateTime.utc(from.year, from.month, from.day, 9);
    return List.generate(4, (index) {
      final slotStart = start.add(Duration(hours: index));
      return {
        'start': slotStart.toIso8601String(),
        'end': slotStart.add(const Duration(minutes: 30)).toIso8601String(),
        'is_available': true,
      };
    });
  }
}
