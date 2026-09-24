import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';
import 'package:medibook/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medibook/features/auth/presentation/pages/login_page.dart';
import 'package:medibook/l10n/gen/app_localizations.dart';

class _MockAuthBloc extends Mock implements AuthBloc {}

const _patient = AuthUser(
  id: 'demo-patient-001',
  displayName: 'MediBook Demo Patient',
  roles: {UserRole.patient},
  permissions: {Permission.bookAppointment},
  organizationId: 'demo-organization',
  clinicIds: {'demo-clinic'},
  email: 'demo.patient@medibook.app',
  localeCode: 'ar',
);

void main() {
  testWidgets('authenticated state leaves login and reaches dashboard', (tester) async {
    final bloc = _MockAuthBloc();
    final states = StreamController<AuthState>.broadcast();
    addTearDown(states.close);

    when(() => bloc.state).thenReturn(const AuthState.authenticating());
    when(() => bloc.stream).thenAnswer((_) => states.stream);

    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: Text('DASHBOARD_ROUTE_REACHED'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: bloc,
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

    states.add(const AuthState.authenticated(_patient));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD_ROUTE_REACHED'), findsOneWidget);
  });
}
