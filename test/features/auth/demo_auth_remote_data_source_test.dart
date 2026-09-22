import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/auth/data/datasources/demo_auth_remote_data_source.dart';

void main() {
  const dataSource = DemoAuthRemoteDataSource();

  test('accepts the documented demo credentials', () async {
    final response = await dataSource.login(
      email: DemoAuthRemoteDataSource.email,
      password: DemoAuthRemoteDataSource.password,
    );

    expect(response.user.id, 'demo-patient-001');
    expect(response.user.isPatient, isTrue);
    expect(response.tokens.accessToken, 'demo-access-token');
  });

  test('rejects incorrect demo credentials', () async {
    expect(
      () => dataSource.login(
        email: DemoAuthRemoteDataSource.email,
        password: 'wrong-password',
      ),
      throwsA(isA<AuthException>()),
    );
  });
}
