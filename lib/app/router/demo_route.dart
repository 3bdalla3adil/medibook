import '../../features/auth/domain/entities/auth_user.dart';

abstract final class DemoRoute {
  static const path = '/demo';

  static bool isDemoUser(AuthUser user) => user.id.startsWith('demo-');

  static String pathFor(AuthUser user) => path;
}
