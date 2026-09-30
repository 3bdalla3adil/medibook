import 'package:flutter/material.dart';

import '../../../../l10n/gen/app_localizations.dart';
import '../../../auth/domain/entities/auth_user.dart';

class DemoProfilePage extends StatelessWidget {
  const DemoProfilePage({super.key, required this.user, required this.role});

  final AuthUser user;
  final String role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.actionSettings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              child: Text(
                user.displayName.isEmpty ? '?' : user.displayName[0],
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          Center(child: Text(user.email ?? '')),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(role),
                ),
                ListTile(
                  leading: const Icon(Icons.business_outlined),
                  title: Text(user.organizationId),
                ),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: Text(l10n.demoWorkflowReady),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.demoWorkflowDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
