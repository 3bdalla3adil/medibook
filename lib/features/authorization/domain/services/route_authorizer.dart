import '../../../auth/domain/entities/auth_user.dart';
import '../entities/route_requirement.dart';

class RouteAuthorizer {
  const RouteAuthorizer();

  bool can(AuthUser? user, RouteRequirement requirement) {
    if (user == null) return false;
    if (requirement.isUnrestricted) return true;

    final roleAllowed = requirement.roles.isEmpty ||
        requirement.roles.any(user.roles.contains);
    final permissionAllowed = requirement.permissions.isEmpty ||
        requirement.permissions.any(user.permissions.contains);

    return roleAllowed && permissionAllowed;
  }
}
