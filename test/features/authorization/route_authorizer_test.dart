import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';
import 'package:medibook/features/authorization/domain/entities/route_requirement.dart';
import 'package:medibook/features/authorization/domain/services/route_authorizer.dart';

void main() {
  const authorizer = RouteAuthorizer();

  const patient = AuthUser(
    id: 'p',
    displayName: 'Patient',
    roles: {UserRole.patient},
    permissions: {
      Permission.viewOwnAppointments,
      Permission.bookAppointment,
      Permission.cancelOwnAppointment,
      Permission.viewOwnMedicalRecord,
      Permission.joinTelehealth,
    },
    organizationId: 'org',
  );

  const doctor = AuthUser(
    id: 'd',
    displayName: 'Doctor',
    roles: {UserRole.doctor},
    permissions: {
      Permission.viewOwnAppointments,
      Permission.viewAnyAppointment,
      Permission.viewAnyMedicalRecord,
      Permission.writePrescription,
      Permission.joinTelehealth,
      Permission.hostTelehealth,
    },
    organizationId: 'org',
  );

  const admin = AuthUser(
    id: 'a',
    displayName: 'Admin',
    roles: {UserRole.orgAdmin},
    permissions: {
      Permission.viewAnyAppointment,
      Permission.manageClinicStaff,
      Permission.viewBilling,
      Permission.processPayment,
      Permission.manageOrganization,
    },
    organizationId: 'org',
  );

  test('patient cannot reach admin routes', () {
    const requirement = RouteRequirement(
      permissions: {
        Permission.manageOrganization,
        Permission.manageClinicStaff,
      },
    );
    expect(authorizer.can(patient, requirement), isFalse);
    expect(authorizer.can(admin, requirement), isTrue);
  });

  test('doctor cannot reach organization admin routes', () {
    const requirement = RouteRequirement(
      permissions: {Permission.manageOrganization},
    );
    expect(authorizer.can(doctor, requirement), isFalse);
    expect(authorizer.can(admin, requirement), isTrue);
  });

  test('doctor routes require doctor role', () {
    const requirement = RouteRequirement(roles: {UserRole.doctor});
    expect(authorizer.can(doctor, requirement), isTrue);
    expect(authorizer.can(patient, requirement), isFalse);
    expect(authorizer.can(admin, requirement), isFalse);
  });

  test('billing requires billing permission', () {
    const requirement = RouteRequirement(
      permissions: {
        Permission.viewBilling,
        Permission.processPayment,
      },
    );
    expect(authorizer.can(admin, requirement), isTrue);
    expect(authorizer.can(patient, requirement), isFalse);
    expect(authorizer.can(doctor, requirement), isFalse);
  });

  test('prescriptions allow prescribing clinicians or own-record readers', () {
    const requirement = RouteRequirement(
      permissions: {
        Permission.writePrescription,
        Permission.viewOwnMedicalRecord,
      },
    );
    expect(authorizer.can(doctor, requirement), isTrue);
    expect(authorizer.can(patient, requirement), isTrue);
    expect(authorizer.can(admin, requirement), isFalse);
  });

  test('null user is never authorized', () {
    expect(
      authorizer.can(null, const RouteRequirement(roles: {UserRole.doctor})),
      isFalse,
    );
  });
}
