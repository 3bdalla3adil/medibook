import '../../../../core/error/result.dart';
import '../entities/auth_user.dart';

class Session {
  const Session({required this.user, required this.expiresAt});
  final AuthUser user;
  final DateTime expiresAt;
}

abstract interface class AuthRepository {
  Future<Result<Session>> login({required String email, required String password});
  Future<Result<Session>> register({
    required String email,
    required String password,
    required String displayName,
  });
  Future<Result<Session>> restoreSession();
  Future<Result<void>> logout({bool revokeOnServer = true});
  Stream<AuthUser?> watchUser();
}
