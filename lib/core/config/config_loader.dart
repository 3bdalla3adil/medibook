import 'package:logging/logging.dart';

import 'app_config.dart';
import 'app_environment.dart';

abstract final class ConfigLoader {
  static AppConfig load() {
    const envName = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    final environment = switch (envName) {
      'prod' => AppEnvironment.prod,
      'staging' => AppEnvironment.staging,
      _ => AppEnvironment.dev,
    };

    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com',
    );

    final config = AppConfig(
      environment: environment,
      apiBaseUrl: baseUrl,
      apiVersion: const String.fromEnvironment('API_VERSION', defaultValue: ''),
      requestTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      logLevel: environment == AppEnvironment.prod ? Level.WARNING : Level.ALL,
      enableSslPinning: const bool.fromEnvironment('ENABLE_SSL_PINNING'),
      enableDeviceIntegrityCheck: const bool.fromEnvironment('ENABLE_DEVICE_INTEGRITY'),
      enableScreenGuard: const bool.fromEnvironment('ENABLE_SCREEN_GUARD', defaultValue: true),
      enableBiometrics: const bool.fromEnvironment('ENABLE_BIOMETRICS'),
      enableDemoAuth: const bool.fromEnvironment('ENABLE_DEMO_AUTH'),
      enableFirebaseAuth: const bool.fromEnvironment('ENABLE_FIREBASE_AUTH'),
      allowCleartextTraffic: const bool.fromEnvironment('ALLOW_CLEARTEXT'),
      maxOutboxAttempts: 8,
      sessionIdleTimeout: const Duration(minutes: 15),
    );

    config.validate();
    return config;
  }
}
