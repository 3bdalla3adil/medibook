import 'package:dio/dio.dart';

import '../../security/phi_redactor.dart';
import '../../security/secure_logger.dart';

class SafeLogInterceptor extends Interceptor {
  SafeLogInterceptor({required this.enabled});

  final bool enabled;
  final _log = SecureLogger('Http');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      _log.debug('-> ${options.method} ${PhiRedactor.redactUri(options.uri)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (enabled) {
      _log.debug('<- ${response.statusCode} '
          '${PhiRedactor.redactUri(response.requestOptions.uri)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      _log.warn('x ${err.requestOptions.method} '
          '${PhiRedactor.redactUri(err.requestOptions.uri)}', data: {
        'type': err.type.name,
        'status': err.response?.statusCode,
      },);
    }
    handler.next(err);
  }
}
