import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/error/result.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/cancel_appointment.dart';
import '../../domain/usecases/get_appointment.dart';

class AppointmentDetailsPage extends StatelessWidget {
  const AppointmentDetailsPage({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _AppointmentDetailsCubit(
        getAppointment: getIt<GetAppointmentUseCase>(),
        cancelAppointment: getIt<CancelAppointmentUseCase>(),
      )..load(appointmentId),
      child: const _AppointmentDetailsView(),
    );
  }
}

class _AppointmentDetailsCubit extends Cubit<_AppointmentDetailsState> {
  _AppointmentDetailsCubit({required this.getAppointment, required this.cancelAppointment})
      : super(const _AppointmentDetailsState.loading());

  final GetAppointmentUseCase getAppointment;
  final CancelAppointmentUseCase cancelAppointment;

  Future<void> load(String id) async {
    final result = await getAppointment(id);
    switch (result) {
      case Ok(value: final value):
        emit(value == null ? const _AppointmentDetailsState.notFound() : _AppointmentDetailsState.ready(value));
      case Err(:final failure):
        emit(_AppointmentDetailsState.error(failure.message));
    }
  }

  Future<bool> cancel(String id) async {
    final result = await cancelAppointment(id);
    switch (result) {
      case Ok(value: final value):
        emit(_AppointmentDetailsState.ready(value));
        return true;
      case Err(:final failure):
        emit(_AppointmentDetailsState.error(failure.message));
        return false;
    }
  }
}

class _AppointmentDetailsState {
  const _AppointmentDetailsState._(this.status, [this.appointment, this.message]);
  const _AppointmentDetailsState.loading() : this._('loading');
  const _AppointmentDetailsState.notFound() : this._('notFound');
  const _AppointmentDetailsState.ready(Appointment a) : this._('ready', a);
  const _AppointmentDetailsState.error(String message) : this._('error', null, message);
  final String status;
  final Appointment? appointment;
  final String? message;
}

class _AppointmentDetailsView extends StatelessWidget {
  const _AppointmentDetailsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.actionDetails)),
      body: BlocBuilder<_AppointmentDetailsCubit, _AppointmentDetailsState>(
        builder: (context, state) {
          if (state.status == 'loading') return const Center(child: CircularProgressIndicator.adaptive());
          if (state.status == 'notFound') return Center(child: Text(l10n.stateEmpty));
          if (state.status == 'error' && state.appointment == null) {
            return Center(child: Text(state.message ?? l10n.errorGeneric));
          }
          final a = state.appointment!;
          final locale = Localizations.localeOf(context).toLanguageTag();
          final date = DateFormat.yMMMMEEEEd(locale).format(a.startsAt.toLocal());
          final time = DateFormat.jm(locale).format(a.startsAt.toLocal());
          final canCancel = a.status.isActive;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.doctorName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(a.serviceName, style: Theme.of(context).textTheme.titleMedium),
                      const Divider(height: 32),
                      _InfoRow(Icons.calendar_today_outlined, date),
                      _InfoRow(Icons.schedule_outlined, time),
                      _InfoRow(
                        a.isTelehealth ? Icons.videocam_outlined : Icons.location_on_outlined,
                        a.isTelehealth ? l10n.appointmentTelehealth : (a.clinicName ?? l10n.appointmentInPerson),
                      ),
                      if (a.roomLabel != null) _InfoRow(Icons.meeting_room_outlined, a.roomLabel!),
                      if (a.notes != null && a.notes!.isNotEmpty) _InfoRow(Icons.notes_outlined, a.notes!),
                    ],
                  ),
                ),
              ),
              if (canCancel) ...[
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  icon: const Icon(Icons.event_busy_outlined),
                  label: Text(l10n.statusCancelled),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.statusCancelled),
                        content: Text(l10n.appointmentsEmptyMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(l10n.statusCancelled),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await context.read<_AppointmentDetailsCubit>().cancel(a.id);
                    }
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
