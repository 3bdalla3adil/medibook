import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_localizations.dart';
class DispenseHistoryPage extends StatelessWidget { const DispenseHistoryPage({super.key}); @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:Text(AppLocalizations.of(c).pharmacyHistoryTitle)),body:const SizedBox.shrink()); }
