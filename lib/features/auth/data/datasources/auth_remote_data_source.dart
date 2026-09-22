import 'package:dio/dio.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/security/token_store.dart';
import '../../domain/entities/auth_user.dart';

class LoginResponse {
  const LoginResponse({required this.tokens, required this.user});
  final AuthTokens tokens;
  final AuthUser user;
}

abstract interface class AuthRemoteDataSource {
  Future<LoginResponse> login({required String email, required String password});
  Future<AuthUser> me();
  Future<void> logout();
}

class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  DioAuthRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<LoginResponse> login({required String email, required String password}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final body = res.data!['data'] as Map<String, dynamic>;
      final tokens = AuthTokens(
        accessToken: body['access_token'] as String,
        refreshToken: body['refresh_token'] as String?,
        accessExpiresAt: DateTime.parse(body['access_expires_at'] as String),
        refreshExpiresAt: body['refresh_expires_at'] == null
            ? null
            : DateTime.parse(body['refresh_expires_at'] as String),
        sessionId: body['session_id'] as String?,
      );

      return LoginResponse(
        tokens: tokens,
        user: _mapUser(body['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<AuthUser> me() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      return _mapUser(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<void>(ApiEndpoints.logout);
    } on DioException {
      // Best-effort.
    }
  }

  AuthUser _mapUser(Map<String, dynamic> json) {
    final roleStrings = (json['roles'] as List?)?.cast<String>() ?? const [];
    final permStrings = (json['permissions'] as List?)?.cast<String>() ?? const [];

    return AuthUser(
      id: json['id'].toString(),
      displayName: json['display_name'] as String? ?? '',
      roles: roleStrings.map(_parseRole).whereType<UserRole>().toSet(),
      permissions: permStrings.map(_parsePermission).whereType<Permission>().toSet(),
      organizationId: json['organization_id'].toString(),
      clinicIds: ((json['clinic_ids'] as List?)?.cast<dynamic>() ?? const [])
          .map((e) => e.toString())
          .toSet(),
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      localeCode: json['locale'] as String?,
    );
  }

  UserRole? _parseRole(String value) {
    for (final r in UserRole.values) {
      if (r.name == value) return r;
    }
    return null;
  }

  Permission? _parsePermission(String value) {
    for (final p in Permission.values) {
      if (p.name == value) return p;
    }
    return null;
  }

  AppException _asException(DioException e) {
    final f = ErrorMapper.fromDio(e);
    return switch (f) {
      UnauthorizedFailure(:final expired) => const AuthException('unauthorized', expired: expired),
      NetworkFailure() || TimeoutFailure() => const NetworkException('network'),
      ForbiddenFailure() => const ServerException('forbidden', statusCode: 403),
      ValidationFailure() => const ServerException('invalid_credentials', statusCode: 400),
      _ => const ServerException('unknown'),
    };
  }
}
