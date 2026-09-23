import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/authorization/domain/entities/route_requirement.dart';
import '../../features/authorization/domain/services/route_authorizer.dart';
import 'routes.dart';

class AuthGuard {
  const AuthGuard(this._bloc);

  final AuthBloc _bloc;
  static const _authorizer = RouteAuthorizer();

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _bloc.state;
    final location = state.matchedLocation;
    final isLoggingIn = location == Routes.login;
    final isRegistering = location == Routes.register;
    final isSplash = location == Routes.splash;
    final isForbidden = location == Routes.forbidden;
    final isAuthEntry = isLoggingIn || isRegistering;

    if (authState is AuthUnknown || authState is AuthRestoring) {
      return isSplash ? null : Routes.splash;
    }

    if (authState is AuthUnauthenticated) {
      return isAuthEntry ? null : Routes.login;
    }

    if (isForbidden) return null;
    if (isAuthEntry || isSplash) return Routes.dashboard;

    final requirement = requirementFor(location);
    if (requirement != null) {
      final denied = requirePermission(context, requirement);
      if (denied != null) return denied;
    }

    return null;
  }

  String? requirePermission(
    BuildContext _,
    RouteRequirement requirement,
  ) {
    final user = _bloc.state.user;
    if (user == null) return Routes.login;
    return _authorizer.can(user, requirement) ? null : Routes.forbidden;
  }

  RouteRequirement? requirementFor(String location) {
    if (location == Routes.bookAppointment) {
      return const RouteRequirement(
        permissions: {Permission.bookAppointment},
      );
    }

    if (location == Routes.appointments || location.startsWith('/appointments/')) {
      return const RouteRequirement(
        permissions: {
          Permission.viewOwnAppointments,
          Permission.viewAnyAppointment,
        },
      );
    }

    if (location.startsWith('/admin/')) {
      return const RouteRequirement(
        permissions: {
          Permission.manageOrganization,
          Permission.manageClinicStaff,
        },
      );
    }

    if (location.startsWith('/doctor/')) {
      return const RouteRequirement(roles: {UserRole.doctor});
    }

    if (location == Routes.consultations) {
      return const RouteRequirement(roles: {UserRole.doctor});
    }

    if (location == Routes.billing) {
      return const RouteRequirement(
        permissions: {
          Permission.viewBilling,
          Permission.processPayment,
        },
      );
    }

    if (location == Routes.prescriptions) {
      return const RouteRequirement(
        permissions: {
          Permission.writePrescription,
          Permission.viewOwnMedicalRecord,
        },
      );
    }

    if (location == Routes.telehealthLobby ||
        location.startsWith('/telehealth/')) {
      return const RouteRequirement(
        permissions: {
          Permission.joinTelehealth,
          Permission.hostTelehealth,
        },
      );
    }

    if (location == Routes.medicalRecords) {
      return const RouteRequirement(
        permissions: {
          Permission.viewOwnMedicalRecord,
          Permission.viewAnyMedicalRecord,
        },
      );
    }

    return null;
  }
}
