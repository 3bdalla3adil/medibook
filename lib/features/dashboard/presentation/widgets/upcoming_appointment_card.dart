import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/routes.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../appointments/domain/entities/appointment.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  const UpcomingAppointmentCard({super.key, required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final canJoin = appointment.isWithinJoinWindow(DateTime.now());

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  appointment.isTelehealth ? Icons.videocam : Icons.local_hospital,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.isTelehealth
                        ? l10n.appointmentTelehealth
                        : l10n.appointmentInPerson,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              appointment.doctorName,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              appointment.serviceName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            _Row(
              icon: Icons.calendar_today_outlined,
              text: DateFormat.yMMMMEEEEd(locale).format(appointment.startsAt.toLocal()),
            ),
            const SizedBox(height: 6),
            _Row(
              icon: Icons.access_time,
              text: DateFormat.jm(locale).format(appointment.startsAt.toLocal()),
            ),
            if (appointment.clinicName != null) ...[
              const SizedBox(height: 6),
              _Row(icon: Icons.place_outlined, text: appointment.clinicName!),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.push(Routes.appointmentDetails(appointment.id)),
                    child: Text(l10n.actionDetails),
                  ),
                ),
                if (appointment.isTelehealth) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: canJoin
                          ? () => context
                              .push(Routes.telehealthSession(appointment.id))
                          : null,
                      icon: const Icon(Icons.videocam),
                      label: Text(
                        canJoin ? l10n.actionJoinNow : l10n.actionJoinLocked,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onPrimaryContainer),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
