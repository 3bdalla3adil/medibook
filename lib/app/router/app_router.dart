import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/presentation/pages/appointment_details_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/appointments/presentation/pages/book_appointment_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
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
          GoRoute(path: Routes.dashboard, builder: (_, __) => const RoleDashboardPage()),
          GoRoute(path: Routes.appointments, builder: (_, __) => const AppointmentsPage()),
          GoRoute(path: Routes.bookAppointment, builder: (_, __) => const BookAppointmentPage()),
          _stub(Routes.services, 'Services'),
          _stub(Routes.medicalRecords, 'Medical records'),
          _stub(Routes.telehealthLobby, 'Telehealth lobby'),
          _stub(Routes.settings, 'Settings'),
          _stub(Routes.doctors, 'Doctors'),
          _stub(Routes.clinics, 'Clinics'),
          _stub(Routes.consultations, 'Consultations'),
          _stub(Routes.prescriptions, 'Prescriptions'),
          _stub(Routes.doctorPatients, 'Doctor patients'),
          _stub(Routes.adminPatients, 'Patients'),
          _stub(Routes.billing, 'Billing'),
          GoRoute(
            path: '/appointments/:id',
            builder: (_, state) =>
                AppointmentDetailsPage(appointmentId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/telehealth/:appointmentId',
            builder: (_, state) =>
                _StubPage(title: 'Telehealth ${state.pathParameters['appointmentId']}'),
          ),
        ],
        errorBuilder: (_, state) =>
            _ErrorPage(message: state.error?.toString() ?? 'Not found'),
      );

  GoRoute _stub(String path, String title) =>
      GoRoute(path: path, builder: (_, __) => _StubPage(title: title));
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

class _StubPage extends StatelessWidget {
  const _StubPage({required this.title});
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
