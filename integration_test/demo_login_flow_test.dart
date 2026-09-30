import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logging/logging.dart';
import 'package:medibook/app/app.dart';
import 'package:medibook/core/config/app_config.dart';
import 'package:medibook/core/config/app_environment.dart';
import 'package:medibook/core/di/injector.dart';
import 'package:medibook/core/di/register_core.dart';
import 'package:medibook/core/di/register_features.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('all demo accounts login and reach isolated local dashboards', (tester) async {
    await resetInjector();

    const config = AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: 'https://api.example.com',
      apiVersion: '/v1',
      requestTimeout: Duration(seconds: 2),
      connectTimeout: Duration(seconds: 1),
      receiveTimeout: Duration(seconds: 2),
      logLevel: Level.WARNING,
      enableSslPinning: false,
      enableDeviceIntegrityCheck: false,
      enableScreenGuard: false,
      enableBiometrics: false,
      enableDemoAuth: true,
      enableFirebaseAuth: false,
      allowCleartextTraffic: false,
      maxOutboxAttempts: 2,
      sessionIdleTimeout: Duration(minutes: 15),
    );

    await registerCore(config, onSessionExpired: () async {});
    await registerFeatures();

    await tester.pumpWidget(const MediBookApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    Future<void> assertDemoLogin({
      required String buttonLabel,
      required String displayName,
      required String firstCard,
    }) async {
      expect(find.text(buttonLabel), findsOneWidget);

      await tester.tap(find.text(buttonLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining(displayName), findsOneWidget);
      expect(find.text(firstCard), findsOneWidget);
      expect(find.byTooltip('تسجيل الخروج'), findsOneWidget);

      await tester.tap(find.text(firstCard));
      await tester.pumpAndSettle();

      // Demo dashboard actions deliberately stay inside the local demo
      // workflow and do not invoke the clinical API.
      expect(find.text('سير العمل التجريبي متاح دون اتصال ولا يتصل بالواجهة الخلفية السريرية.'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('تسجيل الخروج'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(buttonLabel), findsOneWidget);
    }

    await assertDemoLogin(
      buttonLabel: 'المتابعة كمريض',
      displayName: 'MediBook Demo Patient',
      firstCard: 'حجز موعد',
    );

    await assertDemoLogin(
      buttonLabel: 'المتابعة كطبيب',
      displayName: 'MediBook Demo Doctor',
      firstCard: 'جدولي',
    );

    await assertDemoLogin(
      buttonLabel: 'المتابعة كمسؤول',
      displayName: 'MediBook Demo Administrator',
      firstCard: 'إدارة المواعيد',
    );

    await resetInjector();
  });
}
