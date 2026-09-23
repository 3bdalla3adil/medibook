import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/telehealth_session_bloc.dart';

class TelehealthRoomPage extends StatelessWidget {
  const TelehealthRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.telehealthRoom)),
      body: BlocBuilder<TelehealthSessionBloc, TelehealthSessionState>(
        builder: (context, state) => Column(
          children: [
            Expanded(child: Center(child: Text(state.status.name))),
            FilledButton(
              onPressed: () => context.read<TelehealthSessionBloc>().add(
                const TelehealthLeaveRequested(),
              ),
              child: Text(l10n.telehealthLeave),
            ),
          ],
        ),
      ),
    );
  }
}
