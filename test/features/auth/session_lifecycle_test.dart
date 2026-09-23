import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/error/result.dart';
import 'package:medibook/core/security/session_expiry_signal.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';
import 'package:medibook/features/auth/domain/repositories/auth_repository.dart';
import 'package:medibook/features/auth/domain/usecases/login.dart';
import 'package:medibook/features/auth/domain/usecases/logout.dart';
import 'package:medibook/features/auth/domain/usecases/register.dart';
import 'package:medibook/features/auth/domain/usecases/restore_session.dart';
import 'package:medibook/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogin extends Mock implements LoginUseCase {}

class _MockRegister extends Mock implements RegisterUseCase {}

class _MockLogout extends Mock implements LogoutUseCase {}

class _MockRestore extends Mock implements RestoreSessionUseCase {}

class _MockRepository extends Mock implements AuthRepository {}

void main() {
  const user = AuthUser(
    id: 'patient-1',
    displayName: 'Patient',
    roles: {UserRole.patient},
    permissions: {Permission.viewOwnAppointments},
    organizationId: 'org',
  );

  late _MockLogin login;
  late _MockRegister register;
  late _MockLogout logout;
  late _MockRestore restore;
  late _MockRepository repository;
  late SessionExpirySignal signal;

  setUp(() {
    login = _MockLogin();
    register = _MockRegister();
    logout = _MockLogout();
    restore = _MockRestore();
    repository = _MockRepository();
    signal = SessionExpirySignal();

    when(repository.watchUser).thenAnswer((_) => const Stream<AuthUser?>.empty());
    when(() => restore()).thenAnswer(
      (_) async => Ok(
        Session(
          user: user,
          expiresAt: DateTime.utc(2026, 12, 31),
        ),
      ),
    );
    when(() => logout()).thenAnswer((_) async => const Ok(null));
  });

  blocTest<AuthBloc, AuthState>(
    'session expiry transitions authenticated user to unauthenticated',
    build: () => AuthBloc(
      login: login,
      register: register,
      logout: logout,
      restore: restore,
      repository: repository,
      sessionExpirySignal: signal,
    ),
    seed: () => const AuthState.authenticated(user),
    act: (bloc) => signal.notify(),
    expect: () => const [
      AuthState.unauthenticated(),
    ],
  );

  test('restore use case returns the session supplied by the repository', () async {
    final result = await restore();
    expect(result, isA<Ok<Session>>());
  });
}
