import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/security/token_store.dart';
import '../../domain/entities/auth_user.dart';
import 'auth_remote_data_source.dart';

/// Firebase provides identity only. Odoo is the authoritative profile,
/// authorization, session and clinical-data backend.
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({
    required Dio dio,
    FirebaseAuth? auth,
  })  : _dio = dio,
        _auth = auth ?? FirebaseAuth.instance;

  final Dio _dio;
  final FirebaseAuth _auth;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('unauthorized');
      }
      return _exchangeFirebaseIdentity(user);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } on AuthException {
      rethrow;
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<LoginResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('registration_failed');
      }

      await user.updateDisplayName(displayName.trim());
      await user.reload();

      final currentUser = _auth.currentUser ?? user;
      try {
        await currentUser.sendEmailVerification();
      } on FirebaseAuthException {
        // Verification delivery is independent from the Odoo account exchange.
      }

      return _exchangeFirebaseIdentity(currentUser);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } on AuthException {
      rethrow;
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<AuthUser> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw const AuthException('invalid_session');
      }
      return _mapUser(data);
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<void>(ApiEndpoints.logout);
    } on DioException {
      // Server logout is best-effort; local/Firebase sign-out must still happen.
    } finally {
      await _auth.signOut();
    }
  }

  Future<LoginResponse> _exchangeFirebaseIdentity(User user) async {
    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException('firebase_token_unavailable');
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.firebaseExchange,
        data: {'id_token': idToken},
      );
      final body = response.data?['data'];
      if (body is! Map<String, dynamic>) {
        throw const AuthException('invalid_exchange_response');
      }

      final accessToken = body['access_token']?.toString();
      final accessExpiresAt = body['access_expires_at']?.toString();
      if (accessToken == null || accessToken.isEmpty || accessExpiresAt == null) {
        throw const AuthException('invalid_exchange_response');
      }

      final tokens = AuthTokens(
        accessToken: accessToken,
        refreshToken: body['refresh_token']?.toString(),
        accessExpiresAt: DateTime.parse(accessExpiresAt).toUtc(),
        refreshExpiresAt: body['refresh_expires_at'] == null
            ? null
            : DateTime.parse(body['refresh_expires_at'].toString()).toUtc(),
        sessionId: body['session_id']?.toString(),
      );

      final rawUser = body['user'];
      if (rawUser is! Map<String, dynamic>) {
        throw const AuthException('invalid_exchange_response');
      }

      return LoginResponse(tokens: tokens, user: _mapUser(rawUser));
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  AuthUser _mapUser(Map<String, dynamic> json) {
    final roleStrings = (json['roles'] as List?)?.whereType<String>() ?? const <String>[];
    final permStrings =
        (json['permissions'] as List?)?.whereType<String>() ?? const <String>[];

    return AuthUser(
      id: json['id'].toString(),
      displayName: json['display_name']?.toString() ?? '',
      roles: roleStrings.map(_parseRole).whereType<UserRole>().toSet(),
      permissions: permStrings.map(_parsePermission).whereType<Permission>().toSet(),
      organizationId: json['organization_id']?.toString() ?? '',
      clinicIds: ((json['clinic_ids'] as List?)?.map((e) => e.toString()) ??
              const <String>[])
          .toSet(),
      avatarUrl: json['avatar_url']?.toString(),
      email: json['email']?.toString(),
      localeCode: json['locale']?.toString(),
    );
  }

  UserRole? _parseRole(String value) {
    for (final role in UserRole.values) {
      if (role.name == value) return role;
    }
    return null;
  }

  Permission? _parsePermission(String value) {
    for (final permission in Permission.values) {
      if (permission.name == value) return permission;
    }
    return null;
  }

  AppException _asException(DioException e) {
    final failure = ErrorMapper.fromDio(e);
    return switch (failure) {
      UnauthorizedFailure(:final expired) =>
        AuthException('unauthorized', expired: expired),
      NetworkFailure() || TimeoutFailure() => const NetworkException('network'),
      ForbiddenFailure() => const ServerException('forbidden', statusCode: 403),
      ValidationFailure() => const ServerException('validation', statusCode: 422),
      _ => const ServerException('unknown'),
    };
  }

  AppException _mapAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => const AuthException('invalid_email'),
      'user-not-found' => const AuthException('user_not_found'),
      'wrong-password' || 'invalid-credential' => const AuthException('unauthorized'),
      'user-disabled' => const AuthException('user_disabled'),
      'email-already-in-use' => const AuthException('email_already_in_use'),
      'weak-password' => const AuthException('weak_password'),
      'operation-not-allowed' => const AuthException('operation_not_allowed'),
      'too-many-requests' => const AuthException('too_many_requests'),
      'network-request-failed' => const NetworkException('network'),
      _ => AuthException(e.code.isEmpty ? 'firebase_auth' : e.code),
    };
  }
}
