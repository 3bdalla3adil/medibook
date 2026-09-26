import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';
import 'package:medibook/features/dashboard/presentation/pages/role_dashboard_page.dart';
import 'package:medibook/l10n/gen/app_localizations.dart';

const patient = AuthUser(
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
);

const doctor = AuthUser(
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
);

const admin = AuthUser(
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
);

Future<void> pumpDemo(WidgetTester tester, AuthUser user) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: RoleDashboardPage(user: user),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> openCard(
  WidgetTester tester,
  String title,
  String expectedContent,
) async {
  expect(find.text(title), findsOneWidget);
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
  expect(find.text(expectedContent), findsWidgets);
  expect(find.text(title), findsOneWidget);
}

void main() {
  testWidgets('patient can open every local demo workflow', (tester) async {
    final l10n = await _l10n();
    await pumpDemo(tester, patient);

    await openCard(tester, l10n.actionBookAppointment, l10n.demoClinicOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.actionSeeAppointments, l10n.demoAppointmentOneDoctor);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.actionServices, l10n.demoServiceOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.actionMedicalRecords, l10n.demoRecordDiagnosis);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.actionTelehealth, l10n.telehealthLobbyTitle);
  });

  testWidgets('doctor can open every local demo workflow', (tester) async {
    final l10n = await _l10n();
    await pumpDemo(tester, doctor);

    await openCard(tester, l10n.doctorSchedule, l10n.demoAppointmentOneDoctor);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.doctorPatients, l10n.demoPatientOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.doctorConsultations, l10n.demoConsultationOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.doctorPrescriptions, l10n.demoPrescriptionOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.actionTelehealth, l10n.telehealthLobbyTitle);
  });

  testWidgets('administrator can open every local demo workflow', (tester) async {
    final l10n = await _l10n();
    await pumpDemo(tester, admin);

    await openCard(tester, l10n.adminAppointments, l10n.demoAppointmentOneDoctor);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.adminPatients, l10n.demoPatientOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.adminDoctors, l10n.demoDoctorOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.adminClinics, l10n.demoClinicOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openCard(tester, l10n.adminBilling, l10n.demoBillingInvoice);
  });
}

Future<AppLocalizations> _l10n() async {
  return AppLocalizations(const Locale('ar'));
}
