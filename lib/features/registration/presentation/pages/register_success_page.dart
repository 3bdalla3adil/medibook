import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/gen/app_localizations.dart';
class RegisterSuccessPage extends StatelessWidget { const RegisterSuccessPage({super.key}); @override Widget build(BuildContext c){final l=AppLocalizations.of(c);return Scaffold(body:Center(child:Padding(padding:const EdgeInsetsDirectional.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.check_circle_outline,size:64),const SizedBox(height:16),Text(l.registerSuccess),const SizedBox(height:20),FilledButton(onPressed:()=>c.go('/login'),child:Text(l.actionSignIn))]))));}}
