import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/domain/entities/appointment_status.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final timeFmt = DateFormat.jm(locale);
    final dateFmt = DateFormat.MMMEd(locale);

    final statusLabel = _statusLabel(l10n, appointment.status);
    final statusColor = _statusColor(theme, appointment.status);

    return Semantics(
      button: true,
      label: l10n.appointmentSemanticLabel(
        appointment.doctorName,
        statusLabel,
        dateFmt.format(appointment.startsAt.toLocal()),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(Routes.appointmentDetails(appointment.id)),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appointment.doctorName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusChip(label: statusLabel, color: statusColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.serviceName,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _MetaItem(
                      icon: Icons.schedule,
                      text: '${dateFmt.format(appointment.startsAt.toLocal())} · '
                          '${timeFmt.format(appointment.startsAt.toLocal())}',
                    ),
                    if (appointment.clinicName != null)
                      _MetaItem(
                        icon: Icons.local_hospital_outlined,
                        text: appointment.clinicName!,
                      ),
                    if (appointment.isTelehealth)
                      _MetaItem(
                        icon: Icons.videocam_outlined,
                        text: l10n.appointmentTelehealth,
                      ),
                  ],
                ),
                if (appointment.syncStatus != SyncStatus.synced) ...[
                  const SizedBox(height: 12),
                  _SyncNotice(status: appointment.syncStatus),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, AppointmentStatus status) => switch (status) {
        AppointmentStatus.scheduled => l10n.statusScheduled,
        AppointmentStatus.checkedIn => l10n.statusCheckedIn,
        AppointmentStatus.inConsultation => l10n.statusInConsultation,
        AppointmentStatus.completed => l10n.statusCompleted,
        AppointmentStatus.cancelled => l10n.statusCancelled,
        AppointmentStatus.noShow => l10n.statusNoShow,
      };

  Color _statusColor(ThemeData theme, AppointmentStatus status) => switch (status) {
        AppointmentStatus.scheduled => theme.colorScheme.primary,
        AppointmentStatus.checkedIn => theme.colorScheme.tertiary,
        AppointmentStatus.inConsultation => theme.colorScheme.secondary,
        AppointmentStatus.completed => theme.colorScheme.outline,
        AppointmentStatus.cancelled => theme.colorScheme.error,
        AppointmentStatus.noShow => theme.colorScheme.error,
      };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _SyncNotice extends StatelessWidget {
  const _SyncNotice({required this.status});
  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final (icon, text, color) = switch (status) {
      SyncStatus.pending => (
          Icons.cloud_upload_outlined,
          l10n.syncPending,
          theme.colorScheme.tertiary,
        ),
      SyncStatus.conflict => (
          Icons.warning_amber_outlined,
          l10n.syncConflict,
          theme.colorScheme.error,
        ),
      SyncStatus.failed => (
          Icons.error_outline,
          l10n.syncFailed,
          theme.colorScheme.error,
        ),
      _ => (Icons.check, '', theme.colorScheme.outline),
    };

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}
