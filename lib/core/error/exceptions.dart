sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode, this.payload});
  final int? statusCode;
  final Map<String, dynamic>? payload;
}

final class AuthException extends AppException {
  const AuthException(super.message, {this.expired = false});
  final bool expired;
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

final class ParseException extends AppException {
  const ParseException(super.message);
}

final class ConflictException extends AppException {
  const ConflictException(super.message, {this.code = 'conflict'});
  final String code;
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class DeviceIntegrityException extends AppException {
  const DeviceIntegrityException(super.message);
}
