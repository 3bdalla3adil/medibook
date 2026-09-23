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
import '../../features/dashboard/presentation/pages/role_dashboard_page.dart';
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
          GoRoute(path: Routes.services, builder: (_, __) => const _ClinicalPage(title: 'Services')),
          GoRoute(path: Routes.medicalRecords, builder: (_, __) => const _ClinicalPage(title: 'Medical records')),
          GoRoute(path: Routes.telehealthLobby, builder: (_, __) => const _ClinicalPage(title: 'Telehealth')),
          GoRoute(path: Routes.settings, builder: (_, __) => const _ClinicalPage(title: 'Settings')),
          GoRoute(path: Routes.doctors, builder: (_, __) => const _ClinicalPage(title: 'Doctors')),
          GoRoute(path: Routes.clinics, builder: (_, __) => const _ClinicalPage(title: 'Clinics')),
          GoRoute(path: Routes.consultations, builder: (_, __) => const _ClinicalPage(title: 'Consultations')),
          GoRoute(path: Routes.prescriptions, builder: (_, __) => const _ClinicalPage(title: 'Prescriptions')),
          GoRoute(path: Routes.doctorPatients, builder: (_, __) => const _ClinicalPage(title: 'Doctor patients')),
          GoRoute(path: Routes.adminPatients, builder: (_, __) => const _ClinicalPage(title: 'Patients')),
          GoRoute(path: Routes.billing, builder: (_, __) => const _ClinicalPage(title: 'Billing')),
          GoRoute(
            path: '/appointments/:id',
            builder: (_, state) =>
                AppointmentDetailsPage(appointmentId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/telehealth/:appointmentId',
            builder: (_, state) =>
                _ClinicalPage(title: 'Telehealth session'),
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

class _ClinicalPage extends StatelessWidget {
  const _ClinicalPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(title)),
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
