import '../../features/auth/domain/entities/auth_user.dart';

abstract final class DemoRoute {
  static const path = '/demo';

  static bool isDemoUser(AuthUser user) => user.id.startsWith('demo-');

  static String pathFor(AuthUser user) => path;

  /// Demo users enter through the dedicated demo dashboard, but once there
  /// they may navigate to routes backed by the deterministic demo data
  /// sources. Redirecting every route to /demo made those workflows
  /// unreachable.
  static String? redirectFor(AuthUser user, String location) {
    if (!isDemoUser(user)) return null;
    if (location == RoutesPlaceholder.dashboard ||
        location == RoutesPlaceholder.splash ||
        location == RoutesPlaceholder.login ||
        location == RoutesPlaceholder.register) {
      return path;
    }
    return null;
  }
}

abstract final class RoutesPlaceholder {
  static const dashboard = '/dashboard';
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
}
