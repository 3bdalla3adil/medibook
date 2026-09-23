import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/daily_call_service.dart';
import '../bloc/telehealth_session_bloc.dart';

class TelehealthLobbyPage extends StatelessWidget {
  const TelehealthLobbyPage({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => context.read<TelehealthSessionBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Telehealth lobby')),
        body: BlocBuilder<TelehealthSessionBloc, TelehealthSessionState>(
          builder: (context,state)=>Center(child: switch(state.status){
            TelehealthSessionStatus.idle => FilledButton(onPressed:()=>context.read<TelehealthSessionBloc>().add(TelehealthStartRequested(appointmentId)),child:const Text('Join consultation')),
            TelehealthSessionStatus.loading || TelehealthSessionStatus.connecting => const CircularProgressIndicator(),
            TelehealthSessionStatus.error => Text(state.message??'Unable to join'),
            TelehealthSessionStatus.connected => const Text('Connected.'),
            _ => const Text('Session ended.'),
          }),
        ),
      ),
    );
  }
}
