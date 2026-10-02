import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/gen/app_localizations.dart';
class TelehealthHomePage extends StatelessWidget { const TelehealthHomePage({super.key}); @override Widget build(BuildContext c){final l=AppLocalizations.of(c);return Scaffold(appBar:AppBar(title:Text(l.telehealthLobbyTitle)),body:Center(child:Text(l.telehealthRequiresAppointment)));}}
