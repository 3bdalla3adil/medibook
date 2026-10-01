import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injector.dart';
import 'settings/app_settings_controller.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../l10n/gen/app_localizations.dart';
import 'router/app_router.dart';
import 'router/routes.dart';
import 'theme/app_theme.dart';

class MediBookApp extends StatefulWidget {
  const MediBookApp({super.key});

  @override
  State<MediBookApp> createState() => _MediBookAppState();
}

class _MediBookAppState extends State<MediBookApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  Timer? _bootstrapTimeout;
  late final AppSettingsController _settings;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _settings = getIt<AppSettingsController>();
    _router = AppRouter(_authBloc).router;
    _authBloc.add(const AuthBootstrapRequested());

    // Safety net: if nothing resolves in 15s, force unauthenticated.
    _bootstrapTimeout = Timer(const Duration(seconds: 15), () {
      final s = _authBloc.state;
      if (s is AuthUnknown || s is AuthRestoring) {
        _authBloc.add(const AuthSessionExpired());
      }
    });
  }

  @override
  void dispose() {
    _bootstrapTimeout?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settings,
      builder: (context, _) => BlocProvider.value(
        value: _authBloc,
        child: BlocListener<AuthBloc, AuthState>(
          bloc: _authBloc,
          listenWhen: (previous, current) =>
              current is AuthAuthenticated ||
              current is AuthUnauthenticated ||
              current is AuthFailure,
          listener: (context, state) {
            final location = _router.state.matchedLocation;
            if (state is AuthAuthenticated &&
                (location == Routes.login ||
                    location == Routes.register ||
                    location == Routes.splash)) {
              _router.go(Routes.dashboard);
            } else if ((state is AuthUnauthenticated || state is AuthFailure) &&
                location != Routes.login &&
                location != Routes.register) {
              _router.go(Routes.login);
            }
          },
          child: MaterialApp.router(
            title: 'MediBook',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _settings.themeMode,
            routerConfig: _router,
            locale: _settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: media.textScaler.clamp(
                    minScaleFactor: 0.85,
                    maxScaleFactor: 1.6,
                  ),
                ),
                child: child!,
              );
            },
          ),
        ),
      ),
    );
  }
}
