import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/telehealth_session_bloc.dart';

class TelehealthLobbyPage extends StatelessWidget {
  const TelehealthLobbyPage({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.telehealthLobbyTitle)),
      body: BlocBuilder<TelehealthSessionBloc, TelehealthSessionState>(
        builder: (context, state) => Center(
          child: switch (state.status) {
            TelehealthSessionStatus.idle => FilledButton(
                onPressed: () => context.read<TelehealthSessionBloc>().add(
                  TelehealthStartRequested(appointmentId),
                ),
                child: Text(l10n.telehealthJoin),
              ),
            TelehealthSessionStatus.loading ||
            TelehealthSessionStatus.connecting =>
              const CircularProgressIndicator(),
            TelehealthSessionStatus.error =>
              Text(state.message ?? l10n.telehealthUnableToJoin),
            TelehealthSessionStatus.connected => Text(l10n.telehealthConnected),
            _ => Text(l10n.telehealthEnded),
          },
        ),
      ),
    );
  }
}
