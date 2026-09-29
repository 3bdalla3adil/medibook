import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/security/token_store.dart';
import 'package:medibook/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:medibook/features/auth/data/datasources/demo_auth_remote_data_source.dart';
import 'package:medibook/features/auth/data/repositories/demo_auth_repository.dart';

class _FakeLocal implements AuthLocalDataSource {
  AuthTokens? tokens;
  @override Future<AuthTokens?> readTokens() async => tokens;
  @override Future<void> persistTokens(AuthTokens value) async => tokens = value;
  @override Future<void> clear() async => tokens = null;
}

DemoAuthRepository _repository() => DemoAuthRepository(
  remote: DemoAuthRemoteDataSource(),
  local: _FakeLocal(),
);

void main() {
  test('demo session is restored while the repository stays alive', () async {
    final repository = _repository();

    final login = await repository.login(
      email: DemoAuthRemoteDataSource.patientEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    expect(login.isOk, isTrue);
    expect((await repository.restoreSession()).isOk, isTrue);
  });

  test('a new demo repository cannot restore the previous session', () async {
    final firstProcessRepository = _repository();

    await firstProcessRepository.login(
      email: DemoAuthRemoteDataSource.doctorEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    // This represents a fresh application process. Nothing is read from
    // Hive, secure storage, SharedPreferences, Firebase, or the API.
    final newProcessRepository = _repository();

    expect((await newProcessRepository.restoreSession()).isOk, isFalse);
  });
}
