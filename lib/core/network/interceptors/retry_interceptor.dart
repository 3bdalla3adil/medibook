import 'dart:math';

import 'package:dio/dio.dart';

import '../../security/secure_logger.dart';
import '../../sync/backoff.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxAttempts = 3,
    Random? random,
  })  : _dio = dio,
        _random = random ?? Random();

  final Dio _dio;
  final int maxAttempts;
  final Random _random;
  final _log = SecureLogger('RetryInterceptor');

  static const _retryableStatuses = {502, 503, 504, 408, 429};

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra['retry_attempt'] as int?) ?? 0;

    if (attempt >= maxAttempts || !_shouldRetry(err)) {
      return handler.next(err);
    }

    if (options.method == 'POST' && options.extra['idempotent'] != true) {
      return handler.next(err);
    }

    final delay = Backoff.forAttempt(
      attempt,
      random: _random,
      cap: const Duration(seconds: 20),
    );
    _log.warn('Retrying request', data: {
      'method': options.method,
      'attempt': attempt + 1,
    },);

    await Future<void>.delayed(delay);

    options.extra['retry_attempt'] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) => switch (err.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          true,
        DioExceptionType.badResponse =>
          _retryableStatuses.contains(err.response?.statusCode),
        _ => false,
      };
}
