import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/presentation/pages/appointment_details_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/appointments/presentation/pages/book_appointment_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/authorization/presentation/pages/forbidden_page.dart';
import '../../features/clinics/presentation/pages/clinic_list_page.dart';
import '../../features/consultations/presentation/pages/consultation_list_page.dart';
import '../../features/dashboard/presentation/pages/role_dashboard_page.dart';
import '../../features/doctors/presentation/pages/doctor_list_page.dart';
import '../../features/medical_records/presentation/pages/patient_record_view_page.dart';
import '../../features/patients/presentation/pages/patient_directory_page.dart';
import '../../features/prescriptions/presentation/pages/prescription_list_page.dart';
import '../../features/services/presentation/pages/service_list_page.dart';
import '../../l10n/gen/app_localizations.dart';
import 'auth_guard.dart';
import 'routes.dart';
class AppRouter {
  AppRouter(this._authBloc) {
    _guard = AuthGuard(_authBloc);
  }

  final AuthBloc _authBloc;
  late final AuthGuard _guard;

  GoRouter get router => GoRouter(
        initialLocation: Routes.splash,
        debugLogDiagnostics: false,
        refreshListenable: _AuthBlocListenable(_authBloc),
        redirect: (context, state) => _guard.redirect(context, state),
        routes: [
          GoRoute(path: Routes.splash, builder: (_, __) => const _SplashPage()),
          GoRoute(path: Routes.login, builder: (_, __) => const LoginPage()),
          GoRoute(path: Routes.register, builder: (_, __) => const RegisterPage()),
          GoRoute(path: Routes.forbidden, builder: (_, __) => const ForbiddenPage()),
          GoRoute(path: Routes.dashboard, builder: (_, __) => const RoleDashboardPage()),
          GoRoute(path: Routes.appointments, builder: (_, __) => const AppointmentsPage()),
          GoRoute(path: Routes.bookAppointment, builder: (_, __) => const BookAppointmentPage()),
          GoRoute(path: Routes.services, builder: (_, __) => const ServiceListPage()),
          GoRoute(
            path: Routes.medicalRecords,
            builder: (_, __) => PatientRecordViewPage(
              patientId: _authBloc.state.user?.id ?? '',
            ),
          ),
          GoRoute(path: Routes.doctors, builder: (_, __) => const DoctorListPage()),
          GoRoute(path: Routes.clinics, builder: (_, __) => const ClinicListPage()),
          GoRoute(path: Routes.consultations, builder: (_, __) => const ConsultationListPage()),
          GoRoute(path: Routes.prescriptions, builder: (_, __) => const PrescriptionListPage()),
          GoRoute(path: Routes.doctorPatients, builder: (_, __) => const PatientDirectoryPage()),
          GoRoute(path: Routes.adminPatients, builder: (_, __) => const PatientDirectoryPage()),
          GoRoute(
            path: '/appointments/:id',
            builder: (_, state) => AppointmentDetailsPage(
              appointmentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/telehealth/:appointmentId',
            builder: (_, state) => _TelehealthRoutePage(
              appointmentId: state.pathParameters['appointmentId']!,
            ),
          ),
          GoRoute(
            path: Routes.telehealthLobby,
            builder: (_, __) => const _TelehealthLobbyPage(),
          ),
          GoRoute(
            path: Routes.billing,
            builder: (_, __) => const _UnavailableClinicalRoutePage(),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (_, __) => const _UnavailableClinicalRoutePage(),
          ),
        ],
        errorBuilder: (_, state) =>
            _ErrorPage(message: state.error?.toString() ?? 'Not found'),
      );
}

class _AuthBlocListenable extends ChangeNotifier {
  _AuthBlocListenable(this._bloc) {
    _sub = _bloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _bloc;
  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
}

class _TelehealthLobbyPage extends StatelessWidget {
  const _TelehealthLobbyPage();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Telehealth sessions require an appointment.')),
      );
}

class _TelehealthRoutePage extends StatelessWidget {
  const _TelehealthRoutePage({required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).actionTelehealth)),
        body: Center(child: Text(appointmentId)),
      );
}

class _UnavailableClinicalRoutePage extends StatelessWidget {
  const _UnavailableClinicalRoutePage();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('This module is not implemented in Phase 2.')),
      );
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(message)),
      );
}
