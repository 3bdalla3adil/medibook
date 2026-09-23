import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Role-aware landing page. Demo users use local workflow navigation so the
/// demo can be explored without a clinical backend.
class RoleDashboardPage extends StatelessWidget {
  const RoleDashboardPage({super.key, this.user});

  /// Optional explicit user for deterministic previews/tests. Production
  /// routing leaves this null and reads the authenticated user from AuthBloc.
  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final currentUser = user ?? context.read<AuthBloc>().state.user;
    if (currentUser == null) return const SizedBox.shrink();

    // Demo identities must never enter the production dashboard path. The
    // production patient dashboard loads backend data; demo users must remain
    // fully deterministic and offline-capable after authentication.
    if (_isDemoUser(currentUser)) {
      if (currentUser.isPatient) {
        return _DemoRoleDashboard(user: currentUser, kind: _DemoRole.patient);
      }
      if (currentUser.roles.contains(UserRole.doctor)) {
        return _DemoRoleDashboard(user: user, kind: _DemoRole.doctor);
      }
      if (user.roles.contains(UserRole.orgAdmin) ||
          user.roles.contains(UserRole.clinicAdmin) ||
          user.roles.contains(UserRole.superAdmin)) {
        return _DemoRoleDashboard(user: user, kind: _DemoRole.admin);
      }
    }

    if (user.roles.contains(UserRole.doctor)) {
      return _DemoRoleDashboard(user: user, kind: _DemoRole.doctor);
    }
    if (user.roles.contains(UserRole.orgAdmin) ||
        user.roles.contains(UserRole.clinicAdmin) ||
        user.roles.contains(UserRole.superAdmin)) {
      return _DemoRoleDashboard(user: user, kind: _DemoRole.admin);
    }

    return const _UnknownRoleDashboard();
  }

  bool _isDemoUser(AuthUser user) => user.id.startsWith('demo-');
}

enum _DemoRole { patient, doctor, admin }

class _DemoRoleDashboard extends StatelessWidget {
  const _DemoRoleDashboard({required this.user, required this.kind});

  final AuthUser user;
  final _DemoRole kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = switch (kind) {
      _DemoRole.patient => [
          _WorkflowItem(
            l10n.actionBookAppointment,
            Icons.event_available,
            Routes.bookAppointment,
          ),
          _WorkflowItem(
            l10n.actionSeeAppointments,
            Icons.calendar_month,
            Routes.appointments,
          ),
          _WorkflowItem(
            l10n.actionServices,
            Icons.medical_services_outlined,
            Routes.services,
          ),
          _WorkflowItem(
            l10n.actionMedicalRecords,
            Icons.folder_shared_outlined,
            Routes.medicalRecords,
          ),
          _WorkflowItem(
            l10n.actionTelehealth,
            Icons.video_call_outlined,
            Routes.telehealthLobby,
          ),
        ],
      _DemoRole.doctor => [
          _WorkflowItem(
            l10n.doctorSchedule,
            Icons.calendar_today_outlined,
            Routes.appointments,
          ),
          _WorkflowItem(
            l10n.doctorPatients,
            Icons.people_outline,
            Routes.doctorPatients,
          ),
          _WorkflowItem(
            l10n.doctorConsultations,
            Icons.assignment_outlined,
            Routes.consultations,
          ),
          _WorkflowItem(
            l10n.doctorPrescriptions,
            Icons.medication_outlined,
            Routes.prescriptions,
          ),
          _WorkflowItem(
            l10n.actionTelehealth,
            Icons.video_call_outlined,
            Routes.telehealthLobby,
          ),
        ],
      _DemoRole.admin => [
          _WorkflowItem(
            l10n.adminAppointments,
            Icons.calendar_month,
            Routes.appointments,
          ),
          _WorkflowItem(
            l10n.adminPatients,
            Icons.people_outline,
            Routes.adminPatients,
          ),
          _WorkflowItem(
            l10n.adminDoctors,
            Icons.medical_services_outlined,
            Routes.doctors,
          ),
          _WorkflowItem(
            l10n.adminClinics,
            Icons.local_hospital_outlined,
            Routes.clinics,
          ),
        ],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.actionSignOut,
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardGreeting(user.displayName),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      avatar: Icon(_roleIcon(kind), size: 18),
                      label: Text(_roleLabel(l10n, kind)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.demoWorkflowDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisExtent: 128,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push(item.route),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(item.icon, size: 30),
                            const Spacer(),
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _roleIcon(_DemoRole role) => switch (role) {
        _DemoRole.patient => Icons.person_outline,
        _DemoRole.doctor => Icons.medical_services_outlined,
        _DemoRole.admin => Icons.admin_panel_settings_outlined,
      };

  String _roleLabel(AppLocalizations l10n, _DemoRole role) => switch (role) {
        _DemoRole.patient => l10n.rolePatient,
        _DemoRole.doctor => l10n.roleDoctor,
        _DemoRole.admin => l10n.roleAdmin,
      };
}

class _UnknownRoleDashboard extends StatelessWidget {
  const _UnknownRoleDashboard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(child: Text(l10n.errorForbidden)),
    );
  }
}

class _WorkflowItem {
  const _WorkflowItem(this.title, this.icon, this.route);

  final String title;
  final IconData icon;
  final String route;
}
