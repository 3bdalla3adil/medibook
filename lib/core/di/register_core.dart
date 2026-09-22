import '../config/app_config.dart';
import '../firebase/firebase_token_refresher.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../security/biometric_service.dart';
import '../security/certificate_pinning.dart';
import '../security/device_integrity.dart';
import '../security/encryption_key_provider.dart';
import '../security/screen_guard.dart';
import '../security/secure_logger.dart';
import '../security/secure_storage.dart';
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
    ..registerLazySingleton<CertificatePinning>(
      () => CertificatePinning(
        enabled: config.enableSslPinning,
        pinsByHost: const {},
      ),
    )
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
      onSessionExpired: onSessionExpired,
      firebaseTokenRefresher: config.enableFirebaseAuth
          ? const FirebaseTokenRefresher().refresh
          : null,
    ),
  );
}
