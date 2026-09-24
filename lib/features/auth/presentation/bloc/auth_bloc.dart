import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/security/secure_logger.dart';
import '../../../../core/security/session_expiry_signal.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/restore_session.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required RestoreSessionUseCase restore,
    required AuthRepository repository,
    required SessionExpirySignal sessionExpirySignal,
    AuthState initialState = const AuthState.unknown(),
  })  : _login = login,
        _register = register,
        _logout = logout,
        _restore = restore,
        _repository = repository,
        _sessionExpirySignal = sessionExpirySignal,
        super(initialState) {
    on<AuthBootstrapRequested>(_onBootstrap);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onSessionExpired);

    _userSub = _repository.watchUser().listen((user) {
      if (user == null && state is AuthAuthenticated) {
        add(const AuthSessionExpired());
      }
    });

    _sessionSub = _sessionExpirySignal.stream.listen((_) {
      if (!isClosed) add(const AuthSessionExpired());
    });
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final RestoreSessionUseCase _restore;
  final AuthRepository _repository;
  final SessionExpirySignal _sessionExpirySignal;
  final _log = SecureLogger('AuthBloc');

  StreamSubscription<AuthUser?>? _userSub;
  StreamSubscription<void>? _sessionSub;

  Future<void> _onBootstrap(
    AuthBootstrapRequested event,
    Emitter<AuthState> emit,
  ) async {
    final showRestoring = state is AuthUnknown;
    if (showRestoring) {
      emit(const AuthState.restoring());
    }

    final result = await _restore();

    if (state is AuthAuthenticated || state is AuthAuthenticating) {
      return;
    }

    switch (result) {
      case Ok(value: final session):
        emit(AuthState.authenticated(session.user));
      case Err():
        if (showRestoring) {
          emit(const AuthState.unauthenticated());
        }
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());
    final result = await _login(email: event.email, password: event.password);

    switch (result) {
      case Ok(value: final session):
        emit(AuthState.authenticated(session.user));
      case Err(:final failure):
        emit(AuthState.failed(failure));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.authenticating());
    final result = await _register(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );

    switch (result) {
      case Ok(value: final session):
        emit(AuthState.authenticated(session.user));
      case Err(:final failure):
        emit(AuthState.failed(failure));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.unauthenticated());
    final result = await _logout();
    if (result case Err(:final failure)) {
      _log.warn('Server-side logout failed', data: {'code': failure.code});
    }
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.unauthenticated());
    await _logout(revokeOnServer: false);
  }

  @override
  Future<void> close() async {
    await _userSub?.cancel();
    await _sessionSub?.cancel();
    return super.close();
  }
}
