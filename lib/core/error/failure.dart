import 'failure_codes.dart';

sealed class Failure implements Exception {
  const Failure({
    required this.code,
    this.cause,
    this.stackTrace,
    this.fieldErrors = const {},
  });

  final String code;
  final Object? cause;
  final StackTrace? stackTrace;
  final Map<String, List<String>> fieldErrors;

  Failure withStack(StackTrace st);

  @override
  String toString() => 'Failure($code)';
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.cause, super.stackTrace}) : super(code: FailureCodes.network);
  @override
  NetworkFailure withStack(StackTrace st) => NetworkFailure(cause: cause, stackTrace: st);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.cause, super.stackTrace}) : super(code: FailureCodes.timeout);
  @override
  TimeoutFailure withStack(StackTrace st) => TimeoutFailure(cause: cause, stackTrace: st);
}

final class CancelledFailure extends Failure {
  const CancelledFailure({super.cause, super.stackTrace}) : super(code: FailureCodes.cancelled);
  @override
  CancelledFailure withStack(StackTrace st) => CancelledFailure(cause: cause, stackTrace: st);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({this.expired = false, super.cause, super.stackTrace})
      : super(code: expired ? FailureCodes.sessionExpired : FailureCodes.unauthorized);
  final bool expired;
  @override
  UnauthorizedFailure withStack(StackTrace st) =>
      UnauthorizedFailure(expired: expired, cause: cause, stackTrace: st);
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.cause, super.stackTrace}) : super(code: FailureCodes.forbidden);
  @override
  ForbiddenFailure withStack(StackTrace st) => ForbiddenFailure(cause: cause, stackTrace: st);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.cause, super.stackTrace}) : super(code: FailureCodes.notFound);
  @override
  NotFoundFailure withStack(StackTrace st) => NotFoundFailure(cause: cause, stackTrace: st);
}

final class ValidationFailure extends Failure {
  const ValidationFailure({super.fieldErrors, super.cause, super.stackTrace})
      : super(code: FailureCodes.validation);
  @override
  ValidationFailure withStack(StackTrace st) =>
      ValidationFailure(fieldErrors: fieldErrors, cause: cause, stackTrace: st);
}

final class ConflictFailure extends Failure {
  const ConflictFailure({super.code = FailureCodes.conflict, super.cause, super.stackTrace});
  @override
  ConflictFailure withStack(StackTrace st) =>
      ConflictFailure(code: code, cause: cause, stackTrace: st);
}

final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, super.cause, super.stackTrace})
      : super(code: FailureCodes.server);
  final int? statusCode;
  @override
  ServerFailure withStack(StackTrace st) =>
      ServerFailure(statusCode: statusCode, cause: cause, stackTrace: st);
}

final class CacheFailure extends Failure {
  const CacheFailure({super.cause, super.stackTrace}) : super(code: FailureCodes.cache);
  @override
  CacheFailure withStack(StackTrace st) => CacheFailure(cause: cause, stackTrace: st);
}

final class SyncFailure extends Failure {
  const SyncFailure({super.cause, super.stackTrace}) : super(code: FailureCodes.sync);
  @override
  SyncFailure withStack(StackTrace st) => SyncFailure(cause: cause, stackTrace: st);
}

final class DeviceIntegrityFailure extends Failure {
  const DeviceIntegrityFailure({super.cause, super.stackTrace})
      : super(code: FailureCodes.deviceIntegrity);
  @override
  DeviceIntegrityFailure withStack(StackTrace st) =>
      DeviceIntegrityFailure(cause: cause, stackTrace: st);
}

final class UnknownFailure extends Failure {
  const UnknownFailure({super.cause, super.stackTrace}) : super(code: FailureCodes.unknown);
  @override
  UnknownFailure withStack(StackTrace st) => UnknownFailure(cause: cause, stackTrace: st);
}
