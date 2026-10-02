import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_localizations.dart';
class MedicationDetailPage extends StatelessWidget { const MedicationDetailPage({required this.id,super.key}); final String id; @override Widget build(BuildContext c){final l=AppLocalizations.of(c);return Scaffold(appBar:AppBar(title:Text(l.medicationsTitle)),body:Padding(padding:const EdgeInsetsDirectional.all(16),child:Card(child:ListTile(title:Text(id),subtitle:Text(l.medicationsReminderEnabled),trailing:FilledButton(onPressed:(){},child:Text(l.medicationsDoseTaken))))));}}
