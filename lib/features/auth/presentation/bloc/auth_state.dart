part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  AuthUser? get user => switch (this) {
        AuthAuthenticated(:final user) => user,
        _ => null,
      };

  const factory AuthState.unknown() = AuthUnknown;
  const factory AuthState.restoring() = AuthRestoring;
  const factory AuthState.authenticating() = AuthAuthenticating;
  const factory AuthState.authenticated(AuthUser user) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.failed(Failure failure, {AuthUser? previous}) = AuthFailure;

  @override
  List<Object?> get props => [runtimeType, user];
}

final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class AuthRestoring extends AuthState {
  const AuthRestoring();
}

final class AuthAuthenticating extends AuthState {
  const AuthAuthenticating();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  @override
  final AuthUser user;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.failure, {this.previous});
  final Failure failure;
  final AuthUser? previous;
  @override
  List<Object?> get props => [runtimeType, failure.code, previous];
}
