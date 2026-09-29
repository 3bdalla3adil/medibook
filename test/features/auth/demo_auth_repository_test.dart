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

void main() {
  late DemoAuthRepository repository;

  setUp(() {
    repository = DemoAuthRepository(
      remote: DemoAuthRemoteDataSource(),
      local: _FakeLocal(),
    );
  });

  test('demo patient login succeeds without secure storage or API', () async {
    final result = await repository.login(
      email: DemoAuthRemoteDataSource.patientEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    expect(result.isOk, isTrue);
    expect(result.valueOrNull?.user.id, 'demo-patient-001');

    final restored = await repository.restoreSession();
    expect(restored.isOk, isTrue);
    expect(restored.valueOrNull?.user.id, 'demo-patient-001');
  });

  test('demo doctor login succeeds', () async {
    final result = await repository.login(
      email: DemoAuthRemoteDataSource.doctorEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    expect(result.isOk, isTrue);
    expect(result.valueOrNull?.user.id, 'demo-doctor-001');
  });

  test('demo administrator login succeeds', () async {
    final result = await repository.login(
      email: DemoAuthRemoteDataSource.adminEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    expect(result.isOk, isTrue);
    expect(result.valueOrNull?.user.id, 'demo-admin-001');
  });

  test('invalid demo password returns an auth failure, not an exception', () async {
    final result = await repository.login(
      email: DemoAuthRemoteDataSource.patientEmail,
      password: 'wrong-password',
    );

    expect(result.isErr, isTrue);
  });
}
