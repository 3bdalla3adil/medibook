import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failure.dart';
import 'failure_codes.dart';

abstract final class ErrorMapper {
  static Failure fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.cancel:
        return CancelledFailure(cause: e);
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutFailure(cause: e);
      case DioExceptionType.connectionError:
        return NetworkFailure(cause: e);
      case DioExceptionType.badCertificate:
        return NetworkFailure(cause: e);
      case DioExceptionType.badResponse:
        return _fromResponse(e);
      case DioExceptionType.unknown:
        return e.error is AppException
            ? fromException(e.error! as AppException)
            : UnknownFailure(cause: e);
    }
  }

  static Failure _fromResponse(DioException e) {
    final status = e.response?.statusCode ?? 0;
    final body = e.response?.data;
    final code = body is Map ? body['code'] as String? : null;
    final fieldErrors = _extractFieldErrors(body);

    return switch (status) {
      400 => ValidationFailure(fieldErrors: fieldErrors, cause: e),
      401 => UnauthorizedFailure(cause: e),
      403 => ForbiddenFailure(cause: e),
      404 => NotFoundFailure(cause: e),
      409 => ConflictFailure(code: code ?? FailureCodes.conflict, cause: e),
      422 => ValidationFailure(fieldErrors: fieldErrors, cause: e),
      >= 500 => ServerFailure(statusCode: status, cause: e),
      _ => UnknownFailure(cause: e),
    };
  }

  static Map<String, List<String>> _extractFieldErrors(Object? body) {
    if (body is! Map) return const {};
    final raw = body['errors'];
    if (raw is! Map) return const {};
    return raw.map(
      (k, v) => MapEntry(
        k.toString(),
        v is List ? v.map((e) => e.toString()).toList() : <String>[v.toString()],
      ),
    );
  }

  static Failure fromException(AppException e) => switch (e) {
        AuthException(:final expired) => UnauthorizedFailure(expired: expired, cause: e),
        ConflictException(:final code) => ConflictFailure(code: code, cause: e),
        ServerException(:final statusCode) => ServerFailure(statusCode: statusCode, cause: e),
        NetworkException() => NetworkFailure(cause: e),
        CacheException() => CacheFailure(cause: e),
        ParseException() => UnknownFailure(cause: e),
        DeviceIntegrityException() => DeviceIntegrityFailure(cause: e),
      };
}
