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
  test('all demo identities enter the isolated demo route', () {
    expect(DemoRoute.redirectFor(patient, '/'), DemoRoute.path);
    expect(DemoRoute.redirectFor(patient, '/appointments'), DemoRoute.path);
  });

  test('a demo identity already on the demo route is not redirected again', () {
    expect(DemoRoute.redirectFor(patient, DemoRoute.path), isNull);
  });

  test('real users are never redirected into demo mode', () {
    expect(DemoRoute.isDemoUser(realUser), isFalse);
    expect(DemoRoute.redirectFor(realUser, '/'), isNull);
  });
}
