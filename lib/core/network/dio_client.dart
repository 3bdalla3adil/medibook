import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../api_endpoints.dart';
import '../config/app_config.dart';
import '../security/certificate_pinning.dart';
import '../security/token_store.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/safe_log_interceptor.dart';
import 'network_info.dart';

class DioClient {
  DioClient._(this.dio, this._refreshDio);

  final Dio dio;
  final Dio _refreshDio;

  factory DioClient.create({
    required AppConfig config,
    required TokenStore tokenStore,
    required NetworkInfo networkInfo,
    required CertificatePinning pinning,
    required Future<void> Function() onSessionExpired,
    bool enableFirebaseAuth = false,
  }) {
    BaseOptions baseOptions() => BaseOptions(
          baseUrl: '${config.apiBaseUrl}${config.apiVersion}',
          connectTimeout: config.connectTimeout,
          receiveTimeout: config.receiveTimeout,
          sendTimeout: config.requestTimeout,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          headers: const {
            'Accept': 'application/json',
            'X-Client-Platform': 'mobile',
          },
        );

    final refreshDio = Dio(baseOptions())
      ..interceptors.add(SafeLogInterceptor(enabled: config.isDev));
    pinning.apply(refreshDio);

    Future<AuthTokens?> refreshOdooSessionFromFirebase() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final idToken = await user.getIdToken(true);
      if (idToken == null || idToken.isEmpty) return null;

      try {
        final response = await refreshDio.post<Map<String, dynamic>>(
          ApiEndpoints.firebaseExchange,
          data: {'id_token': idToken},
        );
        final data = response.data?['data'];
        if (data is! Map<String, dynamic>) return null;

        final accessToken = data['access_token']?.toString();
        final accessExpiresAt = data['access_expires_at']?.toString();
        if (accessToken == null || accessToken.isEmpty || accessExpiresAt == null) {
          return null;
        }

        return AuthTokens(
          accessToken: accessToken,
          refreshToken: data['refresh_token']?.toString(),
          accessExpiresAt: DateTime.parse(accessExpiresAt).toUtc(),
          refreshExpiresAt: data['refresh_expires_at'] == null
              ? null
              : DateTime.parse(data['refresh_expires_at'].toString()).toUtc(),
          sessionId: data['session_id']?.toString(),
        );
      } on DioException {
        return null;
      }
    }

    final mainDio = Dio(baseOptions());

    mainDio.interceptors.addAll([
      ConnectivityInterceptor(networkInfo),
      AuthInterceptor(
        tokenStore: tokenStore,
        refreshClient: refreshDio,
        onSessionExpired: onSessionExpired,
        firebaseTokenRefresher:
            enableFirebaseAuth ? refreshOdooSessionFromFirebase : null,
      ),
      RetryInterceptor(dio: mainDio),
      if (config.isDev) SafeLogInterceptor(enabled: true),
    ]);

    pinning.apply(mainDio);

    return DioClient._(mainDio, refreshDio);
  }

  void cancelAll() {
    dio.close(force: true);
    _refreshDio.close(force: true);
  }
}
