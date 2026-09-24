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
  test('authentication lifecycle states are distinct for router refreshes', () {
    expect(const AuthState.unknown(), isNot(const AuthState.restoring()));
    expect(
      const AuthState.restoring(),
      isNot(const AuthState.unauthenticated()),
    );
    expect(
      const AuthState.authenticating(),
      isNot(const AuthState.unauthenticated()),
    );
  });

  blocTest<AuthBloc, AuthState>(
    'bootstrap completes to unauthenticated when no session exists',
    build: () {
      final restore = _MockRestore();
      final repository = _MockRepository();

      when(repository.watchUser).thenAnswer(
        (_) => const Stream<AuthUser?>.empty(),
      );
      when(() => restore()).thenAnswer(
        (_) async => const Err(UnauthorizedFailure()),
      );

      return AuthBloc(
        login: _MockLogin(),
        register: _MockRegister(),
        logout: _MockLogout(),
        restore: restore,
        repository: repository,
        sessionExpirySignal: SessionExpirySignal(),
      );
    },
    act: (bloc) => bloc.add(const AuthBootstrapRequested()),
    wait: const Duration(milliseconds: 50),
    expect: () => [
      const AuthState.restoring(),
      const AuthState.unauthenticated(),
    ],
  );
}
