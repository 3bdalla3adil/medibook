import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/app/router/demo_route.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';

const patient = AuthUser(
  id: 'demo-patient-001',
  displayName: 'Demo Patient',
  roles: {UserRole.patient},
  permissions: {Permission.bookAppointment},
  organizationId: 'demo',
  clinicIds: {'clinic'},
  email: 'demo.patient@medibook.app',
);

const realUser = AuthUser(
  id: 'patient-001',
  displayName: 'Real Patient',
  roles: {UserRole.patient},
  permissions: {Permission.bookAppointment},
  organizationId: 'org',
  clinicIds: {'clinic'},
  email: 'patient@example.com',
);

void main() {
  test('demo identities enter the isolated demo route from auth entry points', () {
    expect(DemoRoute.redirectFor(patient, '/'), isNull);
    expect(DemoRoute.redirectFor(patient, '/dashboard'), DemoRoute.path);
    expect(DemoRoute.redirectFor(patient, '/login'), DemoRoute.path);
    expect(DemoRoute.redirectFor(patient, '/splash'), DemoRoute.path);
    expect(DemoRoute.redirectFor(patient, '/appointments'), isNull);
  });

  test('a demo identity already on the demo route is not redirected again', () {
    expect(DemoRoute.redirectFor(patient, DemoRoute.path), isNull);
  });

  test('real users are never redirected into demo mode', () {
    expect(DemoRoute.isDemoUser(realUser), isFalse);
    expect(DemoRoute.redirectFor(realUser, '/'), isNull);
  });
}
