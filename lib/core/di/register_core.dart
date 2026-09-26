import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../security/biometric_service.dart';
import '../security/certificate_pinning.dart';
import '../security/device_integrity.dart';
import '../security/encryption_key_provider.dart';
import '../security/screen_guard.dart';
import '../security/secure_logger.dart';
import '../security/secure_storage.dart';
import '../security/session_expiry_signal.dart';
import '../security/token_store.dart';
import '../storage/hive_local_store.dart';
import '../storage/local_store.dart';
import '../sync/sync_engine.dart';
import '../utils/clock.dart';
import 'injector.dart';
Future<void> registerCore(
  AppConfig config, {
  required Future<void> Function() onSessionExpired,
}) async {
  SecureLogger.configure(level: config.logLevel);

  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<SessionExpirySignal>(SessionExpirySignal())
    ..registerSingleton<Clock>(const SystemClock())
    ..registerLazySingleton<SecureStorage>(FlutterSecureStorageAdapter.new)
    ..registerLazySingleton<TokenStore>(() => TokenStore(getIt<SecureStorage>()))
    ..registerLazySingleton<EncryptionKeyProvider>(
      () => EncryptionKeyProvider(getIt<SecureStorage>()),
    )
    ..registerLazySingleton<NetworkInfo>(ConnectivityNetworkInfo.new)
    ..registerLazySingleton<LocalStore>(
      () => HiveLocalStore(getIt<EncryptionKeyProvider>()),
    )
    ..registerLazySingleton<DeviceIntegrityService>(
      () => const UnavailableDeviceIntegrityService(),
    )
    ..registerLazySingleton<ScreenGuard>(() => const NoopScreenGuard())
    ..registerLazySingleton<BiometricService>(LocalAuthBiometricService.new)
    ..registerLazySingleton<CertificatePinning>(() {
      const pin = String.fromEnvironment('CERTIFICATE_SHA256');
      final host = Uri.parse(config.apiBaseUrl).host;
      if (config.isProd && config.enableSslPinning && pin.isEmpty) {
        throw StateError('Production certificate pinning requires CERTIFICATE_SHA256.');
      }
      return CertificatePinning(
        enabled: config.enableSslPinning,
        pinsByHost: pin.isEmpty ? const {} : {host: {pin}},
      );
    })
    ..registerLazySingleton<SyncEngine>(
      () => SyncEngine(
        store: getIt<LocalStore>(),
        networkInfo: getIt<NetworkInfo>(),
        clock: getIt<Clock>(),
        maxAttempts: config.maxOutboxAttempts,
      ),
    );

  await getIt<LocalStore>().init();
  await getIt<SyncEngine>().start();

  getIt.registerLazySingleton<DioClient>(
    () => DioClient.create(
      config: getIt<AppConfig>(),
      tokenStore: getIt<TokenStore>(),
      networkInfo: getIt<NetworkInfo>(),
      pinning: getIt<CertificatePinning>(),
      onSessionExpired: () async {
        getIt<SessionExpirySignal>().notify();
        await onSessionExpired();
      },
      enableFirebaseAuth: config.enableFirebaseAuth,
    ),
  );
}
