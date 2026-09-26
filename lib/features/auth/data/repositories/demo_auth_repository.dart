import 'dart:async';

import '../../../../core/error/result.dart';
import '../../../../core/security/token_store.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// In-memory authentication repository for the demo environment.
///
/// Demo login must not depend on platform secure-storage availability or a
/// backend API. This keeps the demo path deterministic on a freshly installed
/// APK while the normal repository remains responsible for real sessions.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this._remote);

  final AuthRemoteDataSource _remote;
  final _userController = StreamController<AuthUser?>.broadcast();

  AuthTokens? _tokens;
  AuthUser? _user;

  @override
  Stream<AuthUser?> watchUser() => _userController.stream;

  @override
  Future<Result<Session>> login({
    required String email,
    required String password,
  }) async {
    final result = await guard(() => _remote.login(email: email, password: password));
    return result.map((response) {
      _tokens = response.tokens;
      _user = response.user;
      _userController.add(response.user);
      return Session(
        user: response.user,
        expiresAt: response.tokens.accessExpiresAt,
      );
    });
  }

  @override
  Future<Result<Session>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final result = await guard(
      () => _remote.register(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
    return result.map((response) {
      _tokens = response.tokens;
      _user = response.user;
      _userController.add(response.user);
      return Session(
        user: response.user,
        expiresAt: response.tokens.accessExpiresAt,
      );
    });
  }

  @override
  Future<Result<Session>> restoreSession() async {
    final tokens = _tokens;
    final user = _user;
    if (tokens == null || user == null || tokens.isAccessExpired(DateTime.now().toUtc())) {
      return const Err(UnauthorizedFailure());
    }
    return Ok(Session(user: user, expiresAt: tokens.accessExpiresAt));
  }

  @override
  Future<Result<void>> logout({bool revokeOnServer = true}) async {
    if (revokeOnServer) {
      await guard(() => _remote.logout());
    }
    _tokens = null;
    _user = null;
    _userController.add(null);
    return const Ok(null);
  }

  Future<void> dispose() => _userController.close();
}
