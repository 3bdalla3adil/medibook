import 'package:equatable/equatable.dart';

enum UserRole { patient, doctor, receptionist, clinicAdmin, orgAdmin, superAdmin }

enum Permission {
  viewOwnAppointments,
  viewAnyAppointment,
  bookAppointment,
  cancelOwnAppointment,
  cancelAnyAppointment,
  viewOwnMedicalRecord,
  viewAnyMedicalRecord,
  writePrescription,
  joinTelehealth,
  hostTelehealth,
  manageClinicStaff,
  viewBilling,
  processPayment,
  manageOrganization,
}

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.displayName,
    required this.roles,
    required this.permissions,
    required this.organizationId,
    this.clinicIds = const {},
    this.avatarUrl,
    this.email,
    this.localeCode,
  });

  final String id;
  final String displayName;
  final Set<UserRole> roles;
  final Set<Permission> permissions;
  final String organizationId;
  final Set<String> clinicIds;
  final String? avatarUrl;
  final String? email;
  final String? localeCode;

  bool can(Permission p) => permissions.contains(p);
  bool canAny(Iterable<Permission> ps) => ps.any(permissions.contains);
  bool get isPatient => roles.contains(UserRole.patient);
  bool get isClinician =>
      roles.contains(UserRole.doctor) || roles.contains(UserRole.clinicAdmin);

  @override
  List<Object?> get props => [id, organizationId, roles, permissions];
}
