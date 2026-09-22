import 'package:flutter/material.dart';

import '../../../../l10n/gen/app_localizations.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onBook,
    required this.onServices,
    required this.onTelehealth,
    required this.onRecords,
  });

  final VoidCallback onBook;
  final VoidCallback onServices;
  final VoidCallback onTelehealth;
  final VoidCallback onRecords;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final actions = <_Action>[
      _Action(icon: Icons.add_circle_outline, label: l10n.actionBookAppointment, onTap: onBook),
      _Action(icon: Icons.medical_services_outlined, label: l10n.actionServices, onTap: onServices),
      _Action(icon: Icons.videocam_outlined, label: l10n.actionTelehealth, onTap: onTelehealth),
      _Action(icon: Icons.folder_shared_outlined, label: l10n.actionMedicalRecords, onTap: onRecords),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: wide ? 2.4 : 0.95,
          ),
          itemBuilder: (context, index) => _QuickActionTile(action: actions[index]),
        );
      },
    );
  }
}

class _Action {
  const _Action({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});
  final _Action action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: action.label,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: action.onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action.icon, size: 26, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
