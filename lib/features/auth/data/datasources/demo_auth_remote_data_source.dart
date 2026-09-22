import '../../../../core/error/exceptions.dart';
import '../../../../core/security/token_store.dart';
import '../../domain/entities/auth_user.dart';
import 'auth_remote_data_source.dart';

/// Development/staging-only authentication provider.
///
/// The credentials are intentionally public demo credentials, not a secret.
/// Production builds must reject [AppConfig.enableDemoAuth].
class DemoAuthRemoteDataSource implements AuthRemoteDataSource {
  static const email = 'demo@medibook.app';
  static const password = 'Demo@2026!';

  static const _user = AuthUser(
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
    email: email,
    localeCode: 'ar',
  );

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().toLowerCase() != DemoAuthRemoteDataSource.email ||
        password != DemoAuthRemoteDataSource.password) {
      throw const AuthException('unauthorized');
    }

    final now = DateTime.now().toUtc();
    return LoginResponse(
      tokens: AuthTokens(
        accessToken: 'demo-access-token',
        refreshToken: 'demo-refresh-token',
        accessExpiresAt: now.add(const Duration(hours: 1)),
        refreshExpiresAt: now.add(const Duration(days: 7)),
        sessionId: 'demo-session',
      ),
      user: _user,
    );
  }

  @override
  Future<AuthUser> me() async => _user;

  @override
  Future<void> logout() async {}
}
