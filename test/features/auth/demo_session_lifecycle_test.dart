import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/auth/data/datasources/demo_auth_remote_data_source.dart';
import 'package:medibook/features/auth/data/repositories/demo_auth_repository.dart';

void main() {
  test('demo session is restored while the repository stays alive', () async {
    final repository = DemoAuthRepository(DemoAuthRemoteDataSource());

    final login = await repository.login(
      email: DemoAuthRemoteDataSource.patientEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    expect(login.isOk, isTrue);
    expect((await repository.restoreSession()).isOk, isTrue);
  });

  test('a new demo repository cannot restore the previous session', () async {
    final firstProcessRepository = DemoAuthRepository(DemoAuthRemoteDataSource());

    await firstProcessRepository.login(
      email: DemoAuthRemoteDataSource.doctorEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    // This represents a fresh application process. Nothing is read from
    // Hive, secure storage, SharedPreferences, Firebase, or the API.
    final newProcessRepository = DemoAuthRepository(DemoAuthRemoteDataSource());

    expect((await newProcessRepository.restoreSession()).isOk, isFalse);
  });
}
