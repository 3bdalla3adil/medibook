import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'routes.dart';

class AuthGuard {
  const AuthGuard(this._bloc);
  final AuthBloc _bloc;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _bloc.state;
    final isLoggingIn = state.matchedLocation == Routes.login;
    final isSplash = state.matchedLocation == Routes.splash;

    if (authState is AuthUnknown || authState is AuthRestoring) {
      return isSplash ? null : Routes.splash;
    }

    if (authState is AuthUnauthenticated) {
      return isLoggingIn ? null : Routes.login;
    }

    if (isLoggingIn || isSplash) return Routes.dashboard;

    return null;
  }

  String? requirePermission(BuildContext context, List<Permission> requiredAny) {
    final user = _bloc.state.user;
    if (user == null) return Routes.login;
    if (requiredAny.isEmpty) return null;
    if (user.canAny(requiredAny)) return null;
    return Routes.dashboard;
  }
}
