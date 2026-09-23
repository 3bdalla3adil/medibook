import '../../../auth/domain/entities/auth_user.dart';

enum RouteRequirementMode { any }

class RouteRequirement {
  const RouteRequirement({
    this.permissions = const {},
    this.roles = const {},
    this.mode = RouteRequirementMode.any,
  });

  final Set<Permission> permissions;
  final Set<UserRole> roles;
  final RouteRequirementMode mode;

  bool get isUnrestricted => permissions.isEmpty && roles.isEmpty;
}
