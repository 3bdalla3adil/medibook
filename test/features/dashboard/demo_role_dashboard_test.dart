import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';
import 'package:medibook/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medibook/features/dashboard/presentation/pages/role_dashboard_page.dart';
import 'package:medibook/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthBloc extends Mock implements AuthBloc {}

const _patient = AuthUser(
  id: 'demo-patient-001',
  displayName: 'MediBook Demo Patient',
  roles: {UserRole.patient},
  permissions: {
    Permission.viewOwnAppointments,
    Permission.bookAppointment,
    Permission.cancelOwnAppointment,
    Permission.viewOwnMedicalRecord,
    Permission.joinTelehealth,
  },
  organizationId: 'demo-organization',
  clinicIds: {'demo-clinic'},
  email: 'demo.patient@medibook.app',
  localeCode: 'ar',
);

const _doctor = AuthUser(
  id: 'demo-doctor-001',
  displayName: 'MediBook Demo Doctor',
  roles: {UserRole.doctor},
  permissions: {
    Permission.viewOwnAppointments,
    Permission.viewAnyAppointment,
    Permission.viewAnyMedicalRecord,
    Permission.writePrescription,
    Permission.joinTelehealth,
    Permission.hostTelehealth,
  },
  organizationId: 'demo-organization',
  clinicIds: {'demo-clinic'},
  email: 'demo.doctor@medibook.app',
  localeCode: 'ar',
);

const _admin = AuthUser(
  id: 'demo-admin-001',
  displayName: 'MediBook Demo Administrator',
  roles: {UserRole.orgAdmin},
  permissions: {
    Permission.viewAnyAppointment,
    Permission.viewAnyMedicalRecord,
    Permission.manageClinicStaff,
    Permission.viewBilling,
    Permission.processPayment,
    Permission.manageOrganization,
  },
  organizationId: 'demo-organization',
  clinicIds: {'demo-clinic'},
  email: 'demo.admin@medibook.app',
  localeCode: 'ar',
);

Future<void> _pumpDashboard(WidgetTester tester, AuthUser user) async {
  final bloc = _MockAuthBloc();
  when(() => bloc.state).thenReturn(AuthState.authenticated(user));
  when(() => bloc.stream).thenAnswer((_) => const Stream<AuthState>.empty());

  await tester.pumpWidget(
    BlocProvider<AuthBloc>.value(
      value: bloc,
      child: const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: RoleDashboardPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('demo patient reaches a local dashboard without DashboardBloc', (tester) async {
    await _pumpDashboard(tester, _patient);

    expect(find.text(_patient.displayName), findsOneWidget);
    expect(find.text('حجز موعد'), findsOneWidget);
    expect(find.text('المواعيد'), findsOneWidget);
  });

  testWidgets('demo doctor reaches the local doctor dashboard', (tester) async {
    await _pumpDashboard(tester, _doctor);

    expect(find.text(_doctor.displayName), findsOneWidget);
    expect(find.text('جدولي'), findsOneWidget);
    expect(find.text('مرضاي'), findsOneWidget);
  });

  testWidgets('demo administrator reaches the local admin dashboard', (tester) async {
    await _pumpDashboard(tester, _admin);

    expect(find.text(_admin.displayName), findsOneWidget);
    expect(find.text('إدارة المواعيد'), findsOneWidget);
    expect(find.text('إدارة المرضى'), findsOneWidget);
  });
}
