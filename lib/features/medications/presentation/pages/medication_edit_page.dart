import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_localizations.dart';
class MedicationEditPage extends StatelessWidget { const MedicationEditPage({super.key}); @override Widget build(BuildContext c){final l=AppLocalizations.of(c);return Scaffold(appBar:AppBar(title:Text(l.medicationsAddNew)),body:ListView(padding:const EdgeInsetsDirectional.all(16),children:[TextField(decoration:InputDecoration(labelText:l.medicationsTitle)),const SizedBox(height:16),FilledButton(onPressed:(){},child:Text(l.actionDetails))]));}}
