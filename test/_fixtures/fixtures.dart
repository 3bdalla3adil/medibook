import 'package:medibook/features/appointments/domain/entities/appointment.dart';
import 'package:medibook/features/appointments/domain/entities/appointment_status.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';
import 'package:medibook/features/patients/domain/entities/patient_profile.dart';

final _utcBase = DateTime.utc(2026, 3, 15, 9, 30);

Appointment testAppointment({
  String id = 'a-1',
  AppointmentStatus status = AppointmentStatus.scheduled,
  bool telehealth = false,
  DateTime? startsAt,
}) =>
    Appointment(
      id: id,
      clinicId: 'c-1',
      clinicName: 'Riyadh Central',
      patientId: 'p-1',
      doctorId: 'd-1',
      doctorName: 'Dr. Amina Al-Sayed',
      serviceId: 's-1',
      serviceName: 'General consultation',
      startsAt: startsAt ?? _utcBase,
      duration: const Duration(minutes: 30),
      status: status,
      isTelehealth: telehealth,
      createdAt: _utcBase.subtract(const Duration(days: 3)),
      updatedAt: _utcBase.subtract(const Duration(days: 1)),
      version: 1,
    );

AuthUser testUser({
  Set<UserRole> roles = const {UserRole.patient},
  Set<Permission> permissions = const {
    Permission.viewOwnAppointments,
    Permission.bookAppointment,
    Permission.joinTelehealth,
  },
}) =>
    AuthUser(
      id: 'u-1',
      displayName: 'Sara',
      roles: roles,
      permissions: permissions,
      organizationId: 'org-1',
    );

PatientProfile testProfile() => const PatientProfile(
      id: 'p-1',
      displayName: 'Sara',
      organizationId: 'org-1',
    );
