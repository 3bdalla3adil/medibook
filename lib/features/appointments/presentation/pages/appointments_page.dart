import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_status.dart';
import '../../domain/usecases/get_appointments.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _AppointmentsCubit(getIt<GetAppointmentsUseCase>())..load(),
      child: const _AppointmentsView(),
    );
  }
}

class _AppointmentsCubit extends Cubit<List<Appointment>?> {
  _AppointmentsCubit(this._get) : super(null);
  final GetAppointmentsUseCase _get;

  Future<void> load() async {
    final result = await _get(forceRefresh: true);
    emit(result.valueOrNull ?? const []);
  }
}

class _AppointmentsView extends StatelessWidget {
  const _AppointmentsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardAppointments)),
      body: BlocBuilder<_AppointmentsCubit, List<Appointment>?>(
        builder: (context, appointments) {
          if (appointments == null) return LoadingView(semanticLabel: l10n.stateLoading);
          if (appointments.isEmpty) {
            return EmptyView(
              title: l10n.appointmentsEmptyTitle,
              message: l10n.appointmentsEmptyMessage,
              icon: Icons.event_available_outlined,
            );
          }
          final locale = Localizations.localeOf(context).toLanguageTag();
          final date = DateFormat.MMMEd(locale);
          final time = DateFormat.jm(locale);
          final sorted = [...appointments]..sort((a,b) => a.startsAt.compareTo(b.startsAt));
          return RefreshIndicator.adaptive(
            onRefresh: () => context.read<_AppointmentsCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final a = sorted[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      child: Icon(a.isTelehealth ? Icons.videocam_outlined : Icons.local_hospital_outlined),
                    ),
                    title: Text(a.doctorName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(a.serviceName + '\n' + date.format(a.startsAt.toLocal()) + ' · ' + time.format(a.startsAt.toLocal())),
                    ),
                    isThreeLine: true,
                    trailing: _StatusIcon(status: a.status),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      AppointmentStatus.scheduled => Icons.event_available,
      AppointmentStatus.checkedIn => Icons.how_to_reg,
      AppointmentStatus.inConsultation => Icons.medical_services_outlined,
      AppointmentStatus.completed => Icons.check_circle_outline,
      AppointmentStatus.cancelled => Icons.cancel_outlined,
      AppointmentStatus.noShow => Icons.person_off_outlined,
    };
    return Icon(icon, semanticLabel: status.name);
  }
}
