import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medibook/features/auth/domain/entities/auth_user.dart';
import 'package:medibook/features/dashboard/presentation/pages/demo_workspace_page.dart';
import 'package:medibook/l10n/gen/app_localizations.dart';

const _patient = AuthUser(
  id: 'demo-patient-001',
  displayName: 'MediBook Demo Patient',
  roles: {UserRole.patient},
  permissions: {Permission.bookAppointment},
  organizationId: 'demo-organization',
  email: 'demo.patient@medibook.app',
);

const _doctor = AuthUser(
  id: 'demo-doctor-001',
  displayName: 'MediBook Demo Doctor',
  roles: {UserRole.doctor},
  permissions: {Permission.writePrescription},
  organizationId: 'demo-organization',
  email: 'demo.doctor@medibook.app',
);

const _admin = AuthUser(
  id: 'demo-admin-001',
  displayName: 'MediBook Demo Administrator',
  roles: {UserRole.orgAdmin},
  permissions: {Permission.processPayment},
  organizationId: 'demo-organization',
  email: 'demo.admin@medibook.app',
);

Future<void> _pump(
  WidgetTester tester,
  AuthUser user,
  DemoWorkspace workspace,
) async {
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
      home: DemoWorkspacePage(user: user, workspace: workspace),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('patient can cancel a demo appointment', (tester) async {
    await _pump(tester, _patient, DemoWorkspace.appointments);

    expect(find.text('إلغاء الموعد'), findsOneWidget);
    await tester.tap(find.text('إلغاء الموعد'));
    await tester.pump();

    expect(find.text('تم إلغاء الموعد'), findsOneWidget);
  });

  testWidgets('patient booking requires selecting a doctor', (tester) async {
    await _pump(tester, _patient, DemoWorkspace.booking);

    expect(find.text('الأطباء'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(3));

    final chip = tester.widget<ChoiceChip>(find.byType(ChoiceChip).first);
    expect(chip.onSelected, isNull);
  });

  testWidgets('doctor can sign a demo prescription', (tester) async {
    await _pump(tester, _doctor, DemoWorkspace.prescriptions);

    expect(find.text('اعتماد الوصفة'), findsOneWidget);
    await tester.tap(find.text('اعتماد الوصفة'));
    await tester.pump();

    expect(find.text('مكتمل'), findsNWidgets(2));
  });

  testWidgets('administrator can record a demo payment', (tester) async {
    await _pump(tester, _admin, DemoWorkspace.billing);

    expect(find.text('تسجيل الدفع'), findsOneWidget);
    await tester.tap(find.text('تسجيل الدفع'));
    await tester.pump();

    expect(find.text('مدفوعة'), findsOneWidget);
  });
}
