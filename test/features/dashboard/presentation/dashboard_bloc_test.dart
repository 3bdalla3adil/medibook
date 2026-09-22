import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medibook/core/error/failure.dart';
import 'package:medibook/core/error/result.dart';
import 'package:medibook/core/network/network_info.dart';
import 'package:medibook/core/utils/clock.dart';
import 'package:medibook/features/appointments/domain/entities/appointment.dart';
import 'package:medibook/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:medibook/features/appointments/domain/usecases/get_appointments.dart';
import 'package:medibook/features/appointments/domain/usecases/get_upcoming_appointment.dart';
import 'package:medibook/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:medibook/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:medibook/features/patients/domain/entities/patient_profile.dart';
import 'package:medibook/features/patients/domain/usecases/get_patient_profile.dart';

import '../../../_fixtures/fixtures.dart';

class _MockGetProfile extends Mock implements GetPatientProfileUseCase {}
class _MockGetAppointments extends Mock implements GetAppointmentsUseCase {}
class _MockGetUpcoming extends Mock implements GetUpcomingAppointmentUseCase {}
class _MockAppointmentRepo extends Mock implements AppointmentRepository {}
class _MockNetwork extends Mock implements NetworkInfo {}

void main() {
  late _MockGetProfile getProfile;
  late _MockGetAppointments getAppointments;
  late _MockGetUpcoming getUpcoming;
  late _MockAppointmentRepo appointmentRepo;
  late _MockNetwork network;

  setUp(() {
    getProfile = _MockGetProfile();
    getAppointments = _MockGetAppointments();
    getUpcoming = _MockGetUpcoming();
    appointmentRepo = _MockAppointmentRepo();
    network = _MockNetwork();

    when(() => appointmentRepo.watchAppointments())
        .thenAnswer((_) => const Stream<Appointment>.empty());
    when(() => network.onStatusChange).thenAnswer((_) => const Stream<bool>.empty());
  });

  DashboardBloc build() => DashboardBloc(
        getProfile: getProfile,
        getAppointments: getAppointments,
        getUpcoming: getUpcoming,
        appointmentRepository: appointmentRepo,
        networkInfo: network,
        clock: FixedClock(DateTime.utc(2026, 3, 15, 8)),
      );

  blocTest<DashboardBloc, DashboardState>(
    'emits loading then ready on successful load',
    build: build,
    setUp: () {
      when(() => network.isOnline()).thenAnswer((_) async => true);
      when(() => getProfile())
          .thenAnswer((_) async => Ok<PatientProfile?>(testProfile()));
      when(() => getAppointments(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Ok<List<Appointment>>([testAppointment()]));
      when(() => getUpcoming())
          .thenAnswer((_) async => Ok<Appointment?>(testAppointment()));
    },
    act: (bloc) => bloc.add(const DashboardStarted()),
    expect: () => [
      isA<DashboardState>().having((s) => s.status, 'status', DashboardStatus.loading),
      isA<DashboardState>()
          .having((s) => s.status, 'status', DashboardStatus.ready)
          .having((s) => s.appointments, 'appointments', hasLength(1))
          .having((s) => s.isOffline, 'isOffline', false),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'emits error state when profile fails and no cache',
    build: build,
    setUp: () {
      when(() => network.isOnline()).thenAnswer((_) async => true);
      when(() => getProfile())
          .thenAnswer((_) async => const Err<PatientProfile?>(NetworkFailure()));
      when(() => getAppointments(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => const Ok<List<Appointment>>([]));
      when(() => getUpcoming())
          .thenAnswer((_) async => const Ok<Appointment?>(null));
    },
    act: (bloc) => bloc.add(const DashboardStarted()),
    expect: () => [
      isA<DashboardState>().having((s) => s.status, 'status', DashboardStatus.loading),
      isA<DashboardState>()
          .having((s) => s.status, 'status', DashboardStatus.error)
          .having((s) => s.failure, 'failure', isA<NetworkFailure>()),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'marks offline when connectivity is unavailable',
    build: build,
    setUp: () {
      when(() => network.isOnline()).thenAnswer((_) async => false);
      when(() => getProfile())
          .thenAnswer((_) async => Ok<PatientProfile?>(testProfile()));
      when(() => getAppointments(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Ok<List<Appointment>>([testAppointment()]));
      when(() => getUpcoming())
          .thenAnswer((_) async => Ok<Appointment?>(testAppointment()));
    },
    act: (bloc) => bloc.add(const DashboardStarted()),
    expect: () => [
      isA<DashboardState>().having((s) => s.status, 'status', DashboardStatus.loading),
      isA<DashboardState>()
          .having((s) => s.status, 'status', DashboardStatus.ready)
          .having((s) => s.isOffline, 'isOffline', true),
    ],
  );
}
