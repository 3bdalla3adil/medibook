import '../../features/auth/domain/entities/auth_user.dart';
import 'routes.dart';

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
    if (location == '/' ||
        location == Routes.dashboard ||
        location == Routes.splash ||
        location == Routes.login ||
        location == Routes.register) {
      return path;
    }
    return null;
  }
}
