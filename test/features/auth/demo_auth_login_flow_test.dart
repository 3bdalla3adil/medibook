import 'package:flutter_test/flutter_test.dart';

import 'package:medibook/features/auth/data/datasources/demo_auth_remote_data_source.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';

void main() {
  late DemoAuthRemoteDataSource dataSource;

  setUp(() {
    dataSource = DemoAuthRemoteDataSource();
  });

  test('patient demo credentials authenticate as patient', () async {
    final response = await dataSource.login(
      email: DemoAuthRemoteDataSource.patientEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    expect(response.user.id, 'demo-patient-001');
    expect(response.user.roles, {UserRole.patient});
    expect(response.tokens.accessToken, 'demo-access-demo-patient-001');
  });

  test('doctor demo credentials authenticate as doctor', () async {
    final response = await dataSource.login(
      email: DemoAuthRemoteDataSource.doctorEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    expect(response.user.id, 'demo-doctor-001');
    expect(response.user.roles, {UserRole.doctor});
    expect(response.tokens.accessToken, 'demo-access-demo-doctor-001');
  });

  test('administrator demo credentials authenticate as organization admin', () async {
    final response = await dataSource.login(
      email: DemoAuthRemoteDataSource.adminEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    expect(response.user.id, 'demo-admin-001');
    expect(response.user.roles, {UserRole.orgAdmin});
    expect(response.tokens.accessToken, 'demo-access-demo-admin-001');
  });
}
