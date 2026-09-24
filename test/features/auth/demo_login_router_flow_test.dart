import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:medibook/app/router/app_router.dart';
import 'package:medibook/core/config/app_config.dart';
import 'package:medibook/core/config/app_environment.dart';
import 'package:medibook/core/di/injector.dart';
import 'package:medibook/core/error/failure.dart';
import 'package:medibook/core/error/result.dart';
import 'package:medibook/core/security/session_expiry_signal.dart';
import 'package:medibook/features/auth/data/datasources/demo_auth_remote_data_source.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';
import 'package:medibook/features/auth/domain/repositories/auth_repository.dart';
import 'package:medibook/features/auth/domain/usecases/login.dart';
import 'package:medibook/features/auth/domain/usecases/logout.dart';
import 'package:medibook/features/auth/domain/usecases/register.dart';
import 'package:medibook/features/auth/domain/usecases/restore_session.dart';
import 'package:medibook/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medibook/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late AuthBloc authBloc;
  late DemoAuthRepository repository;
  late _MockLogin login;
  late _MockRestoreSession restore;

  setUp(() async {
    await resetInjector();
    getIt.registerSingleton<AppConfig>(
      const AppConfig(
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
      ),
    );

    repository = DemoAuthRepository();
    login = _MockLogin();
    restore = _MockRestoreSession();
    when(() => restore()).thenAnswer(
      (_) async => const Err(UnauthorizedFailure()),
    );
    when(() => login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((invocation) async {
      final email = invocation.namedArguments[#email] as String;
      final user = switch (email) {
        DemoAuthRemoteDataSource.patientEmail => const AuthUser(
          id: 'demo-patient-001',
          displayName: 'MediBook Demo Patient',
          roles: {UserRole.patient},
          permissions: {Permission.viewOwnAppointments},
        ),
        DemoAuthRemoteDataSource.doctorEmail => const AuthUser(
          id: 'demo-doctor-001',
          displayName: 'MediBook Demo Doctor',
          roles: {UserRole.doctor},
          permissions: {Permission.viewOwnAppointments},
        ),
        DemoAuthRemoteDataSource.adminEmail => const AuthUser(
          id: 'demo-admin-001',
          displayName: 'MediBook Demo Administrator',
          roles: {UserRole.orgAdmin},
          permissions: {Permission.manageOrganization},
        ),
        _ => throw StateError('Unexpected demo email: $email'),
      };
      return Ok(
        Session(
          user: user,
          expiresAt: DateTime.utc(2027),
        ),
      );
    });
    authBloc = AuthBloc(
      login: login,
      register: RegisterUseCase(repository),
      logout: LogoutUseCase(repository),
      restore: restore,
      repository: repository,
      sessionExpirySignal: SessionExpirySignal(),
      initialState: const AuthState.unauthenticated(),
    );
  });

  tearDown(() async {
    await authBloc.close();
    await resetInjector();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    final router = AppRouter(authBloc).router;
    await tester.pumpWidget(
      BlocProvider.value(
        value: authBloc,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );

    await tester.pump();
    expect(find.text('المتابعة كمريض'), findsOneWidget);
  }

  Future<void> loginAndAssertDashboard(
    WidgetTester tester, {
    required String buttonLabel,
    required String displayName,
    required Set<UserRole> roles,
  }) async {
    await tester.tap(find.text(buttonLabel));
    await tester.pumpAndSettle();

    expect(authBloc.state, isA<AuthAuthenticated>());
    final user = authBloc.state.user;
    expect(user, isNotNull);
    expect(user!.displayName, displayName);
    expect(user.roles, roles);
    expect(find.textContaining(displayName), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);
  }

  testWidgets(
    'patient demo login reaches a rendered local dashboard',
    (tester) async {
      await pumpApp(tester);

      await loginAndAssertDashboard(
        tester,
        buttonLabel: 'المتابعة كمريض',
        displayName: 'MediBook Demo Patient',
        roles: {UserRole.patient},
      );
    },
  );

  testWidgets(
    'doctor demo login reaches a rendered local dashboard',
    (tester) async {
      await pumpApp(tester);

      await loginAndAssertDashboard(
        tester,
        buttonLabel: 'المتابعة كطبيب',
        displayName: 'MediBook Demo Doctor',
        roles: {UserRole.doctor},
      );
    },
  );

  testWidgets(
    'administrator demo login reaches a rendered local dashboard',
    (tester) async {
      await pumpApp(tester);

      await loginAndAssertDashboard(
        tester,
        buttonLabel: 'المتابعة كمسؤول',
        displayName: 'MediBook Demo Administrator',
        roles: {UserRole.orgAdmin},
      );
    },
  );
}

class _MockLogin extends Mock implements LoginUseCase {}

class _MockRestoreSession extends Mock implements RestoreSessionUseCase {}

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository()
      : _remote = DemoAuthRemoteDataSource(),
        _userController = StreamController<AuthUser?>.broadcast();

  final DemoAuthRemoteDataSource _remote;
  final StreamController<AuthUser?> _userController;

  @override
  Future<Result<Session>> login({
    required String email,
    required String password,
  }) async {
    final response = await _remote.login(email: email, password: password);
    _userController.add(response.user);
    return Ok(
      Session(
        user: response.user,
        expiresAt: response.tokens.accessExpiresAt,
      ),
    );
  }

  @override
  Future<Result<Session>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return const Err(UnauthorizedFailure());
  }

  @override
  Future<Result<Session>> restoreSession() async {
    return const Err(UnauthorizedFailure());
  }

  @override
  Future<Result<void>> logout({bool revokeOnServer = true}) async {
    _userController.add(null);
    return const Ok(null);
  }

  @override
  Stream<AuthUser?> watchUser() => _userController.stream;
}
