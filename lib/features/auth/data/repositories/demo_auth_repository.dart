import 'dart:async';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/security/token_store.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// Hybrid repository used when demo authentication is enabled.
///
/// Demo identities stay deterministic and in-memory. Real Firebase users
/// delegated by [DemoAuthRemoteDataSource] use the same secure token/session
/// persistence as production authentication, so a real Firebase account
/// survives app restarts.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final _userController = StreamController<AuthUser?>.broadcast();

  AuthTokens? _demoTokens;
  AuthUser? _demoUser;

  @override
  Stream<AuthUser?> watchUser() => _userController.stream;

  @override
  Future<Result<Session>> login({
    required String email,
    required String password,
  }) async {
    final result = await guard(
      () => _remote.login(email: email, password: password),
    );

    return result.mapAsync((response) async {
      final isDemo = response.tokens.accessToken.startsWith('demo-access-');

      if (isDemo) {
        _demoTokens = response.tokens;
        _demoUser = response.user;
      } else {
        await _local.persistTokens(response.tokens);
      }

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

    return result.mapAsync((response) async {
      // Registration in hybrid mode is Firebase-backed, never a demo
      // identity. Persist the Firebase ID token securely for restoration.
      await _local.persistTokens(response.tokens);
      _userController.add(response.user);
      return Session(
        user: response.user,
        expiresAt: response.tokens.accessExpiresAt,
      );
    });
  }

  @override
  Future<Result<Session>> restoreSession() async {
    final demoTokens = _demoTokens;
    final demoUser = _demoUser;
    if (demoTokens != null &&
        demoUser != null &&
        !demoTokens.isAccessExpired(DateTime.now().toUtc())) {
      _userController.add(demoUser);
      return Ok(
        Session(user: demoUser, expiresAt: demoTokens.accessExpiresAt),
      );
    }

    final tokens = await _local.readTokens();
    if (tokens == null) return const Err(UnauthorizedFailure());

    if (tokens.isRefreshExpired(DateTime.now().toUtc())) {
      await _local.clear();
      return const Err(UnauthorizedFailure(expired: true));
    }

    final result = await guard(() => _remote.me());
    return result.map((user) {
      _userController.add(user);
      return Session(user: user, expiresAt: tokens.accessExpiresAt);
    });
  }

  @override
  Future<Result<void>> logout({bool revokeOnServer = true}) async {
    if (revokeOnServer) {
      await guard(() => _remote.logout());
    }

    _demoTokens = null;
    _demoUser = null;
    await _local.clear();
    _userController.add(null);
    return const Ok(null);
  }

  Future<void> dispose() => _userController.close();
}
