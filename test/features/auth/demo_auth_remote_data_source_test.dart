import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/error/exceptions.dart';
import 'package:medibook/features/auth/data/datasources/demo_auth_remote_data_source.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';

void main() {
  final dataSource = DemoAuthRemoteDataSource();

  test('accepts the patient demo credentials', () async {
    final response = await dataSource.login(
      email: DemoAuthRemoteDataSource.patientEmail,
      password: DemoAuthRemoteDataSource.password,
    );

    expect(response.user.id, 'demo-patient-001');
    expect(response.user.isPatient, isTrue);
    expect(
      response.tokens.accessToken,
      'demo-access-demo-patient-001',
    );
  });

  test('accepts doctor and administrator demo credentials', () async {
    final doctor = await dataSource.login(
      email: DemoAuthRemoteDataSource.doctorEmail,
      password: DemoAuthRemoteDataSource.password,
    );
    expect(doctor.user.roles, contains(UserRole.doctor));
    expect(
      doctor.tokens.accessToken,
      'demo-access-demo-doctor-001',
    );

    final admin = await dataSource.login(
      email: DemoAuthRemoteDataSource.adminEmail,
      password: DemoAuthRemoteDataSource.password,
    );
    expect(admin.user.roles, contains(UserRole.orgAdmin));
    expect(
      admin.tokens.accessToken,
      'demo-access-demo-admin-001',
    );
  });

  test('rejects incorrect demo credentials', () async {
    expect(
      () => dataSource.login(
        email: DemoAuthRemoteDataSource.patientEmail,
        password: 'wrong-password',
      ),
      throwsA(isA<AuthException>()),
    );
  });
}
