import 'package:dio/dio.dart';

import '../network_info.dart';

class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._networkInfo);

  final NetworkInfo _networkInfo;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['bypass_connectivity_check'] == true) {
      return handler.next(options);
    }

    if (!await _networkInfo.isOnline()) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'offline',
        ),
        true,
      );
    }
    handler.next(options);
  }
}
