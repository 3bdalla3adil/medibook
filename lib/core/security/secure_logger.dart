import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'phi_redactor.dart';

class SecureLogger {
  SecureLogger._(this._logger);

  final Logger _logger;
  static final Map<String, SecureLogger> _cache = {};

  factory SecureLogger(String name) =>
      _cache.putIfAbsent(name, () => SecureLogger._(Logger(name)));

  static void configure({required Level level}) {
    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      if (kReleaseMode) return;
      debugPrint('[${record.level.name}] ${record.loggerName}: ${record.message}');
    });
  }

  void debug(String message, {Map<String, Object?>? data}) =>
      _log(Level.FINE, message, data);

  void info(String message, {Map<String, Object?>? data}) =>
      _log(Level.INFO, message, data);

  void warn(String message, {Object? error, StackTrace? st, Map<String, Object?>? data}) =>
      _log(Level.WARNING, message, data, error: error, st: st);

  void error(String message, {Object? error, StackTrace? st, Map<String, Object?>? data}) =>
      _log(Level.SEVERE, message, data, error: error, st: st);

  void _log(
    Level level,
    String message,
    Map<String, Object?>? data, {
    Object? error,
    StackTrace? st,
  }) {
    if (!_logger.isLoggable(level)) return;

    final safeMessage = PhiRedactor.redact(message);
    final safeData = data == null
        ? null
        : PhiRedactor.redactValue(data) as Map<String, Object?>?;
    final safeError = error == null ? null : PhiRedactor.redact(error.toString());

    _logger.log(
      level,
      safeData == null ? safeMessage : '$safeMessage | $safeData',
      safeError,
      st == null ? null : StackTrace.fromString(PhiRedactor.redact(st.toString())),
    );
  }
}
