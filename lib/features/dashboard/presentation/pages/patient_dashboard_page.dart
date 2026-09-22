import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/appointment_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_actions.dart';
import '../widgets/upcoming_appointment_card.dart';

class PatientDashboardPage extends StatelessWidget {
  const PatientDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardBloc>()..add(const DashboardStarted()),
      child: const _PatientDashboardView(),
    );
  }
}

class _PatientDashboardView extends StatelessWidget {
  const _PatientDashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading && !state.hasData) {
              return LoadingView(semanticLabel: l10n.stateLoading);
            }

            if (state.showFullScreenError) {
              return ErrorView(
                message: l10n.errorGeneric,
                onRetry: () => context
                    .read<DashboardBloc>()
                    .add(const DashboardRefreshed()),
              );
            }

            return Column(
              children: [
                if (state.isOffline)
                  OfflineBanner(pendingCount: state.pendingCount),
                Expanded(
                  child: RefreshIndicator.adaptive(
                    onRefresh: () async {
                      final bloc = context.read<DashboardBloc>();
                      bloc.add(const DashboardRefreshed());
                      await bloc.stream
                          .firstWhere((s) => !s.isRefreshing)
                          .timeout(
                            const Duration(seconds: 10),
                            onTimeout: () => bloc.state,
                          );
                    },
                    child: _DashboardBody(state: state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = state.profile;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: DashboardHeader(
            displayName: profile?.displayName ?? l10n.dashboardGreetingFallback,
            avatarUrl: profile?.avatarUrl,
            lastSyncedAt: state.lastSyncedAt,
            isOffline: state.isOffline,
          ),
        ),
        SliverToBoxAdapter(
          child: _Section(
            title: l10n.dashboardUpcoming,
            child: state.upcomingAppointment == null
                ? _EmptyUpcoming()
                : UpcomingAppointmentCard(appointment: state.upcomingAppointment!),
          ),
        ),
        SliverToBoxAdapter(
          child: _Section(
            title: l10n.dashboardQuickActions,
            child: QuickActions(
              onBook: () => context.push(Routes.bookAppointment),
              onServices: () => context.push(Routes.services),
              onTelehealth: () => context.push(Routes.telehealthLobby),
              onRecords: () => context.push(Routes.medicalRecords),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _Section(
            title: l10n.dashboardAppointments,
            trailing: state.appointments.isNotEmpty
                ? TextButton(
                    onPressed: () => context.push(Routes.appointments),
                    child: Text(l10n.actionSeeAll),
                  )
                : null,
            child: state.appointments.isEmpty
                ? EmptyView(
                    title: l10n.appointmentsEmptyTitle,
                    message: l10n.appointmentsEmptyMessage,
                    icon: Icons.event_available_outlined,
                    action: FilledButton(
                      onPressed: () => context.push(Routes.bookAppointment),
                      child: Text(l10n.actionBookAppointment),
                    ),
                  )
                : Column(
                    children: [
                      for (final appointment in state.appointments.take(5))
                        Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: 12),
                          child: AppointmentCard(appointment: appointment),
                        ),
                    ],
                  ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EmptyUpcoming extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Row(
          children: [
            Icon(Icons.event_note_outlined, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.appointmentsNoUpcoming,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
