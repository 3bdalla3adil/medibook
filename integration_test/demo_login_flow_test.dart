import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medibook/app/app.dart';
import 'package:medibook/core/config/app_config.dart';
import 'package:medibook/core/config/app_environment.dart';
import 'package:medibook/core/di/injector.dart';
import 'package:medibook/core/di/register_core.dart';
import 'package:medibook/core/di/register_features.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo patient login reaches dashboard with deterministic data', (tester) async {
    await resetInjector();

    final config = AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: 'https://api.example.com',
      apiVersion: '/v1',
      requestTimeout: const Duration(seconds: 2),
      connectTimeout: const Duration(seconds: 1),
      receiveTimeout: const Duration(seconds: 2),
      logLevel: Level.WARNING,
      enableSslPinning: false,
      enableDeviceIntegrityCheck: false,
      enableScreenGuard: false,
      enableBiometrics: false,
      enableDemoAuth: true,
      enableFirebaseAuth: false,
      allowCleartextTraffic: false,
      maxOutboxAttempts: 2,
      sessionIdleTimeout: const Duration(minutes: 15),
    );

    await registerCore(config, onSessionExpired: () async {});
    await registerFeatures();

    await tester.pumpWidget(const MediBookApp());
    await tester.pumpAndSettle();

    expect(find.text('المتابعة كمريض'), findsOneWidget);

    await tester.tap(find.text('المتابعة كمريض'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Demo Patient'), findsOneWidget);
    expect(find.text('General Consultation'), findsOneWidget);
    expect(find.text('Follow-up Consultation'), findsOneWidget);
  });
}
