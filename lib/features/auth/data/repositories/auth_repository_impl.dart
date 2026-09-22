import 'dart:async';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/local_store.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required LocalStore store,
  })  : _remote = remote,
        _local = local,
        _store = store;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final LocalStore _store;

  final _userController = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> watchUser() => _userController.stream;

  @override
  Future<Result<Session>> login({
    required String email,
    required String password,
  }) async {
    final result = await guard(() => _remote.login(email: email, password: password));
    return result.mapAsync((response) async {
      await _local.persistTokens(response.tokens);
      _userController.add(response.user);
      return Session(user: response.user, expiresAt: response.tokens.accessExpiresAt);
    });
  }

  @override
  Future<Result<Session>> restoreSession() async {
    final tokens = await _local.readTokens();
    if (tokens == null) return const Err(UnauthorizedFailure());

    if (tokens.isRefreshExpired(DateTime.now().toUtc())) {
      await _local.clear();
      return const Err(UnauthorizedFailure(expired: true));
    }

    final result = await guard(() => _remote.me());
    return result.mapAsync((user) async {
      _userController.add(user);
      return Session(user: user, expiresAt: tokens.accessExpiresAt);
    });
  }

  @override
  Future<Result<void>> logout({bool revokeOnServer = true}) async {
    if (revokeOnServer) {
      await guard(() => _remote.logout());
    }
    await _store.wipe();
    await _local.clear();
    _userController.add(null);
    return const Ok(null);
  }
}
