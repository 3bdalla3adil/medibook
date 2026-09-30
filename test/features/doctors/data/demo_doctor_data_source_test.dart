import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/doctors/data/datasources/doctor_demo_data_source.dart';

void main() {
  const source = DemoDoctorRemoteDataSource();

  test('demo doctor source returns deterministic doctor without network', () async {
    final doctors = await source.fetchDoctors();

    expect(doctors, hasLength(1));
    expect(doctors.single.json['id'], 'demo-doctor-001');
    expect(doctors.single.json['display_name'], 'Dr. Demo');
  });

  test('demo doctor source returns profile and assignments', () async {
    final doctor = await source.fetchDoctor('demo-doctor-001');
    final assignments = await source.fetchAssignments('demo-doctor-001');

    expect(doctor?.json['license_number'], 'DEMO-001');
    expect(assignments, hasLength(1));
    expect(assignments.single.json['clinic_id'], 'demo-clinic-001');
  });

  test('demo doctor availability is typed and deterministic', () async {
    final slots = await source.fetchAvailability(
      doctorId: 'demo-doctor-001',
      clinicId: 'demo-clinic-001',
      serviceId: 'demo-service-001',
      from: DateTime(2026, 10, 1),
      to: DateTime(2026, 10, 2),
    );

    expect(slots, hasLength(4));
    expect(slots.every((slot) => slot.toDomain().isBookable), isTrue);
  });
}
