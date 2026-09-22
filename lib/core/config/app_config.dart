import 'package:logging/logging.dart';

import 'app_environment.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.apiVersion,
    required this.requestTimeout,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.logLevel,
    required this.enableSslPinning,
    required this.enableDeviceIntegrityCheck,
    required this.enableScreenGuard,
    required this.enableBiometrics,
    required this.allowCleartextTraffic,
    required this.maxOutboxAttempts,
    required this.sessionIdleTimeout,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String apiVersion;
  final Duration requestTimeout;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Level logLevel;
  final bool enableSslPinning;
  final bool enableDeviceIntegrityCheck;
  final bool enableScreenGuard;
  final bool enableBiometrics;
  final bool allowCleartextTraffic;
  final int maxOutboxAttempts;
  final Duration sessionIdleTimeout;

  bool get isProd => environment == AppEnvironment.prod;
  bool get isDev => environment == AppEnvironment.dev;

  Uri resolve(String path) => Uri.parse('$apiBaseUrl$apiVersion$path');

  void validate() {
    if (isProd) {
      assert(!allowCleartextTraffic, 'Cleartext traffic forbidden in production.');
      assert(apiBaseUrl.startsWith('https://'), 'Production API must use HTTPS.');
    }
  }
}
