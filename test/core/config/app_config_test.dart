import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:medibook/core/config/app_config.dart';
import 'package:medibook/core/config/app_environment.dart';

void main() {
  AppConfig config({
    required AppEnvironment environment,
    required bool demo,
  }) {
    return AppConfig(
      environment: environment,
      apiBaseUrl: 'https://api.medibook.test',
      apiVersion: '/v1',
      requestTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      logLevel: Level.WARNING,
      enableSslPinning: false,
      enableDeviceIntegrityCheck: false,
      enableScreenGuard: true,
      enableBiometrics: false,
      enableDemoAuth: demo,
      enableFirebaseAuth: false,
      allowCleartextTraffic: false,
      maxOutboxAttempts: 8,
      sessionIdleTimeout: const Duration(minutes: 15),
    );
  }

  test('demo auth is accepted outside production', () {
    expect(() => config(environment: AppEnvironment.dev, demo: true).validate(), returnsNormally);
    expect(() => config(environment: AppEnvironment.staging, demo: true).validate(), returnsNormally);
  });

  test('demo auth is rejected in production', () {
    expect(
      () => config(environment: AppEnvironment.prod, demo: true).validate(),
      throwsStateError,
    );
    expect(
      () => config(environment: AppEnvironment.prod, demo: false).validate(),
      returnsNormally,
    );
  });
}
