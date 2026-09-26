import 'dart:async';

import 'package:dio/dio.dart';

import '../../security/secure_logger.dart';
import '../../security/token_store.dart';
import '../api_endpoints.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStore tokenStore,
    required Dio refreshClient,
    required Future<void> Function() onSessionExpired,
    this.firebaseTokenRefresher,
  })  : _tokenStore = tokenStore,
        _refreshClient = refreshClient,
        _onSessionExpired = onSessionExpired;

  final TokenStore _tokenStore;
  final Dio _refreshClient;
  final Future<void> Function() _onSessionExpired;
  final Future<AuthTokens?> Function()? firebaseTokenRefresher;
  final _log = SecureLogger('AuthInterceptor');

  Completer<AuthTokens?>? _refreshInFlight;

  static const _anonymous = {ApiEndpoints.firebaseExchange, ApiEndpoints.login, ApiEndpoints.register, ApiEndpoints.refresh};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_anonymous.contains(options.path)) return handler.next(options);

    final tokens = await _tokenStore.read();
    if (tokens == null) return handler.next(options);

    options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final responseData = err.response?.data;
    final serverCode = responseData is Map ? responseData['code']?.toString() : null;
    if (status == 403 && serverCode == 'account_deactivated') {
      await _tokenStore.clear();
      await _onSessionExpired();
      return handler.next(err);
    }
    final isAuthError = status == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    final isRefreshCall = err.requestOptions.path == ApiEndpoints.refresh;

    if (!isAuthError || alreadyRetried || isRefreshCall) {
      return handler.next(err);
    }

    final tokens = await (_refreshInFlight?.future ?? _startRefresh());

    if (tokens == null) {
      await _onSessionExpired();
      return handler.next(err);
    }

    try {
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      options.extra['retried'] = true;
      final response = await _refreshClient.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  Future<AuthTokens?> _startRefresh() {
    final completer = Completer<AuthTokens?>();
    _refreshInFlight = completer;

    _performRefresh().then((tokens) {
      _refreshInFlight = null;
      completer.complete(tokens);
    }).catchError((Object e) {
      _refreshInFlight = null;
      completer.complete(null);
    });

    return completer.future;
  }

  Future<AuthTokens?> _performRefresh() async {
    if (firebaseTokenRefresher != null) {
      try {
        final refreshed = await firebaseTokenRefresher!();
        if (refreshed != null) {
          await _tokenStore.write(refreshed);
          _log.info('Odoo access token refreshed through Firebase identity exchange');
        }
        return refreshed;
      } catch (_) {
        await _tokenStore.clear();
        return null;
      }
    }

    final current = await _tokenStore.read();
    final refreshToken = current?.refreshToken;
    if (current == null || refreshToken == null) return null;

    try {
      final res = await _refreshClient.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      final data = res.data?['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      final refreshed = AuthTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String? ?? refreshToken,
        accessExpiresAt: DateTime.parse(data['access_expires_at'] as String),
        refreshExpiresAt: data['refresh_expires_at'] == null
            ? current.refreshExpiresAt
            : DateTime.parse(data['refresh_expires_at'] as String),
        sessionId: data['session_id'] as String? ?? current.sessionId,
      );

      await _tokenStore.write(refreshed);
      _log.info('Access token refreshed');
      return refreshed;
    } on DioException catch (e) {
      _log.warn('Token refresh failed', data: {'status': e.response?.statusCode});
      await _tokenStore.clear();
      return null;
    }
  }
}
