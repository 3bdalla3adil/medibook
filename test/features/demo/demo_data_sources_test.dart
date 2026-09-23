import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/demo/demo_seed.dart';
import 'package:medibook/features/appointments/data/repositories/appointment_demo_repository.dart';
import 'package:medibook/features/doctors/data/datasources/doctor_demo_data_source.dart';
import 'package:medibook/features/clinics/data/datasources/clinic_demo_data_source.dart';
import 'package:medibook/features/services/data/datasources/service_demo_data_source.dart';
import 'package:medibook/features/patients/data/datasources/patient_demo_data_source.dart';
import 'package:medibook/core/utils/clock.dart';

void main() {
  test('demo seed is deterministic', () {
    final first = DemoSeed.appointments().map((e) => e.json).toList();
    final second = DemoSeed.appointments().map((e) => e.json).toList();
    expect(first, equals(second));
    expect(first.length, 2);
    expect(DemoSeed.patient().toDomain().displayName, 'Demo Patient');
  });

  test('demo clinical sources never require Dio', () async {
    expect((await const DemoClinicRemoteDataSource().fetchClinics()).length, 1);
    expect((await const DemoServiceRemoteDataSource().fetchServices()).length, 1);
    expect((await const DemoDoctorRemoteDataSource().fetchDoctors()).length, 1);
    expect((await const DemoPatientRemoteDataSource().fetchCurrent())?.id, DemoSeed.patientId);
  });

  test('demo appointment repository is deterministic and mutable in memory', () async {
    final repository = DemoAppointmentRepository(
      FixedClock(DateTime.utc(2026, 9, 23, 8)),
    );
    final result = await repository.getAppointments();
    expect(result.valueOrNull, hasLength(2));
    expect(result.valueOrNull!.first.id, 'demo-appointment-001');
  });
}
