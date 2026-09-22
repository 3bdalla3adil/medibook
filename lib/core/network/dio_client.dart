import 'package:dio/dio.dart';

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
    Future<AuthTokens?> Function()? firebaseTokenRefresher,
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

    final mainDio = Dio(baseOptions());

    mainDio.interceptors.addAll([
      ConnectivityInterceptor(networkInfo),
      AuthInterceptor(
        tokenStore: tokenStore,
        refreshClient: refreshDio,
        onSessionExpired: onSessionExpired,
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
