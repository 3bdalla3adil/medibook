import 'dart:convert';

import 'secure_storage.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
    required this.sessionId,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime accessExpiresAt;
  final DateTime? refreshExpiresAt;
  final String? sessionId;

  bool isAccessExpired(DateTime now, {Duration skew = const Duration(seconds: 30)}) =>
      now.isAfter(accessExpiresAt.subtract(skew));

  bool isRefreshExpired(DateTime now) =>
      refreshExpiresAt != null && now.isAfter(refreshExpiresAt!);

  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? accessExpiresAt,
    DateTime? refreshExpiresAt,
    String? sessionId,
  }) =>
      AuthTokens(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        accessExpiresAt: accessExpiresAt ?? this.accessExpiresAt,
        refreshExpiresAt: refreshExpiresAt ?? this.refreshExpiresAt,
        sessionId: sessionId ?? this.sessionId,
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'access_expires_at': accessExpiresAt.toUtc().toIso8601String(),
        'refresh_expires_at': refreshExpiresAt?.toUtc().toIso8601String(),
        'session_id': sessionId,
      };

  static AuthTokens? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final access = map['access_token'] as String?;
      final exp = map['access_expires_at'] as String?;
      if (access == null || exp == null) return null;
      final refreshExp = map['refresh_expires_at'] as String?;
      return AuthTokens(
        accessToken: access,
        refreshToken: map['refresh_token'] as String?,
        accessExpiresAt: DateTime.parse(exp),
        refreshExpiresAt: refreshExp == null ? null : DateTime.parse(refreshExp),
        sessionId: map['session_id'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

class TokenStore {
  TokenStore(this._storage);

  static const _key = 'auth.tokens.v1';

  final SecureStorage _storage;
  AuthTokens? _cached;

  Future<AuthTokens?> read() async {
    if (_cached != null) return _cached;
    final raw = await _storage.read(_key);
    _cached = AuthTokens.tryParse(raw);
    return _cached;
  }

  Future<void> write(AuthTokens tokens) async {
    _cached = tokens;
    await _storage.write(_key, jsonEncode(tokens.toJson()));
  }

  Future<void> clear() async {
    _cached = null;
    await _storage.delete(_key);
  }
}
