import '../../../../core/error/exceptions.dart';
import '../../../../core/security/token_store.dart';
import '../../domain/entities/auth_user.dart';
import 'auth_remote_data_source.dart';

/// Development/staging-only demo authentication provider.
class DemoAuthRemoteDataSource implements AuthRemoteDataSource {
  DemoAuthRemoteDataSource({this.firebase});

  final AuthRemoteDataSource? firebase;
  static const password = 'Demo@2026!';

  static const patientEmail = 'demo.patient@medibook.app';
  static const doctorEmail = 'demo.doctor@medibook.app';
  static const adminEmail = 'demo.admin@medibook.app';

  static const patientCredentials = DemoCredentials(
    email: patientEmail, password: password, label: 'Patient',
  );
  static const doctorCredentials = DemoCredentials(
    email: doctorEmail, password: password, label: 'Doctor',
  );
  static const adminCredentials = DemoCredentials(
    email: adminEmail, password: password, label: 'Admin',
  );

  static const _patient = AuthUser(
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
    email: patientEmail,
    localeCode: 'ar',
  );

  static const _doctor = AuthUser(
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
    email: doctorEmail,
    localeCode: 'ar',
  );

  static const _admin = AuthUser(
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
    email: adminEmail,
    localeCode: 'ar',
  );

  AuthUser? _activeUser;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    if (password != DemoAuthRemoteDataSource.password) {
      throw const AuthException('unauthorized');
    }

    final normalizedEmail = email.trim().toLowerCase();
    final user = switch (normalizedEmail) {
      DemoAuthRemoteDataSource.patientEmail => _patient,
      DemoAuthRemoteDataSource.doctorEmail => _doctor,
      DemoAuthRemoteDataSource.adminEmail => _admin,
      _ => null,
    };

    if (user == null) {
      final provider = firebase;
      if (provider == null) throw const AuthException('unauthorized');
      return provider.login(email: email, password: password);
    }

    _activeUser = user;
    final now = DateTime.now().toUtc();
    return LoginResponse(
      tokens: AuthTokens(
        accessToken: 'demo-access-${user.id}',
        refreshToken: 'demo-refresh-${user.id}',
        accessExpiresAt: now.add(const Duration(hours: 1)),
        refreshExpiresAt: now.add(const Duration(days: 7)),
        sessionId: 'demo-session-${user.id}',
      ),
      user: user,
    );
  }

  @override
  Future<LoginResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final provider = firebase;
    if (provider == null) {
      throw const AuthException('registration_disabled');
    }
    return provider.register(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<AuthUser> me() async {
    final user = _activeUser;
    if (user != null) return user;
    final provider = firebase;
    if (provider == null) throw const AuthException('unauthorized');
    return provider.me();
  }

  @override
  Future<void> logout() async {
    _activeUser = null;
    await firebase?.logout();
  }
}

class DemoCredentials {
  const DemoCredentials({
    required this.email,
    required this.password,
    required this.label,
  });

  final String email;
  final String password;
  final String label;
}
