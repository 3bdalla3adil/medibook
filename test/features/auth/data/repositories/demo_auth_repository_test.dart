import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/security/token_store.dart';
import 'package:medibook/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:medibook/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:medibook/features/auth/data/repositories/demo_auth_repository.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';

class _FakeRemote implements AuthRemoteDataSource {
  _FakeRemote(this.response);

  LoginResponse response;
  AuthUser? meUser;
  int loginCalls = 0;
  int registerCalls = 0;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    return response;
  }

  @override
  Future<LoginResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    registerCalls++;
    return response;
  }

  @override
  Future<AuthUser> me() async => meUser ?? response.user;

  @override
  Future<void> logout() async {}
}

class _FakeLocal implements AuthLocalDataSource {
  AuthTokens? tokens;

  @override
  Future<AuthTokens?> readTokens() async => tokens;

  @override
  Future<void> persistTokens(AuthTokens value) async => tokens = value;

  @override
  Future<void> clear() async => tokens = null;
}

const _user = AuthUser(
  id: 'firebase-user-001',
  displayName: 'Firebase Patient',
  roles: {UserRole.patient},
  permissions: {
    Permission.viewOwnAppointments,
    Permission.bookAppointment,
    Permission.cancelOwnAppointment,
    Permission.viewOwnMedicalRecord,
    Permission.joinTelehealth,
  },
  organizationId: 'default',
  clinicIds: {},
  email: 'firebase.patient@example.com',
  localeCode: 'ar',
);

AuthTokens _tokens(String accessToken) {
  final now = DateTime.now().toUtc();
  return AuthTokens(
    accessToken: accessToken,
    refreshToken: null,
    accessExpiresAt: now.add(const Duration(hours: 1)),
    refreshExpiresAt: now.add(const Duration(days: 30)),
    sessionId: 'session-001',
  );
}

void main() {
  test('real Firebase-backed login persists its session', () async {
    final local = _FakeLocal();
    final remote = _FakeRemote(
      LoginResponse(tokens: _tokens('firebase-id-token'), user: _user),
    );
    final repository = DemoAuthRepository(remote: remote, local: local);

    final result = await repository.login(
      email: _user.email!,
      password: 'Password@123',
    );

    expect(result.isOk, isTrue);
    expect(local.tokens?.accessToken, 'firebase-id-token');
  });

  test('real Firebase-backed session restores through remote me()', () async {
    final local = _FakeLocal()..tokens = _tokens('firebase-id-token');
    final remote = _FakeRemote(
      LoginResponse(tokens: _tokens('firebase-id-token'), user: _user),
    )..meUser = _user;
    final repository = DemoAuthRepository(remote: remote, local: local);

    final result = await repository.restoreSession();

    expect(result.isOk, isTrue);
    expect(remote.loginCalls, 0);
    expect(remote.meUser?.id, 'firebase-user-001');
  });
}
