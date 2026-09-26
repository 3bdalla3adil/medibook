import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/demo/demo_seed.dart';
import 'package:medibook/core/utils/clock.dart';
import 'package:medibook/features/appointments/data/repositories/appointment_demo_repository.dart';
import 'package:medibook/features/appointments/domain/entities/appointment.dart';
import 'package:medibook/features/appointments/domain/entities/appointment_status.dart';
import 'package:medibook/features/appointments/domain/repositories/appointment_repository.dart';

class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 9, 26, 20);
}

void main() {
  late AppointmentRepository repository;

  setUp(() {
    repository = DemoAppointmentRepository(_FixedClock());
  });

  test('demo appointment create and cancel are realtime and memory-only', () async {
    final appointment = Appointment(
      id: 'demo-created-001',
      clinicId: DemoSeed.clinicId,
      clinicName: 'MediBook Demo Clinic',
      patientId: DemoSeed.patientId,
      doctorId: DemoSeed.doctorId,
      doctorName: 'Dr. Demo',
      serviceId: DemoSeed.serviceId,
      serviceName: 'General Consultation',
      startsAt: DateTime.utc(2026, 10, 30, 9),
      duration: const Duration(minutes: 30),
      status: AppointmentStatus.scheduled,
      isTelehealth: true,
      createdAt: DateTime.utc(2026, 9, 26),
      updatedAt: DateTime.utc(2026, 9, 26),
    );

    expect((await repository.createAppointment(appointment)).isOk, isTrue);
    expect((await repository.getAppointment(appointment.id)).isOk, isTrue);

    expect(
      (await repository.cancelAppointment(appointment.id, reason: 'Demo')).isOk,
      isTrue,
    );

    final cancelled = await repository.getAppointment(appointment.id);
    expect(cancelled.isOk, isTrue);
    expect(cancelled.valueOrNull?.status, AppointmentStatus.cancelled);

    // A new repository is a new demo process and starts from the seed only.
    final fresh = DemoAppointmentRepository(_FixedClock());
    expect((await fresh.getAppointment(appointment.id)).valueOrNull, isNull);
  });
}
