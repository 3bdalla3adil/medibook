import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/auth/presentation/bloc/auth_bloc.dart';

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
}
