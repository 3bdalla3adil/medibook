import '../../../../core/security/token_store.dart';

abstract interface class AuthLocalDataSource {
  Future<AuthTokens?> readTokens();
  Future<void> persistTokens(AuthTokens tokens);
  Future<void> clear();
}

class SecureAuthLocalDataSource implements AuthLocalDataSource {
  SecureAuthLocalDataSource(this._store);
  final TokenStore _store;

  @override
  Future<AuthTokens?> readTokens() => _store.read();

  @override
  Future<void> persistTokens(AuthTokens tokens) => _store.write(tokens);

  @override
  Future<void> clear() => _store.clear();
}
