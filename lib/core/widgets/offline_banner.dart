import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.pendingCount = 0});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final message = pendingCount > 0
        ? l10n.offlineWithPending(pendingCount)
        : l10n.offlineReadOnly;

    return Material(
      color: theme.colorScheme.tertiaryContainer,
      child: Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.cloud_off, size: 20, color: theme.colorScheme.onTertiaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
