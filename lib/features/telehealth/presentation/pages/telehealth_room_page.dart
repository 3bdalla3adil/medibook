import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/telehealth_session_bloc.dart';

class TelehealthRoomPage extends StatelessWidget {
  const TelehealthRoomPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Telehealth')),
    body: BlocBuilder<TelehealthSessionBloc, TelehealthSessionState>(
      builder: (context,state)=>Column(children:[
        Expanded(child: Center(child: Text(state.status.name))),
        FilledButton(onPressed:()=>context.read<TelehealthSessionBloc>().add(const TelehealthLeaveRequested()),child:const Text('Leave')),
      ]),
    ),
  );
}
