import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/registration_draft.dart';
import '../bloc/registration_bloc.dart';

class RegisterPage extends StatelessWidget { const RegisterPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(AppLocalizations.of(context).registerTitle)),body:const _RegisterForm()); }
class _RegisterForm extends StatefulWidget { const _RegisterForm(); @override State<_RegisterForm> createState()=>_RegisterFormState(); }
class _RegisterFormState extends State<_RegisterForm>{ final email=TextEditingController(),password=TextEditingController(),name=TextEditingController(); @override void dispose(){email.dispose();password.dispose();name.dispose();super.dispose();} @override Widget build(BuildContext c){final l=AppLocalizations.of(c);return BlocListener<RegistrationBloc,RegistrationState>(listener:(c,s){if(s.status==RegistrationStatus.success)c.go('/register/success');if(s.status==RegistrationStatus.failure)ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text(l.registerUnavailable)));},child:ListView(padding:const EdgeInsetsDirectional.all(20),children:[TextField(controller:name,decoration:InputDecoration(labelText:l.registerNameLabel)),const SizedBox(height:12),TextField(controller:email,decoration:InputDecoration(labelText:l.loginEmailLabel)),const SizedBox(height:12),TextField(controller:password,obscureText:true,decoration:InputDecoration(labelText:l.loginPasswordLabel)),const SizedBox(height:20),FilledButton(onPressed:()=>context.read<RegistrationBloc>().add(RegistrationSubmitted(RegistrationDraft(email:email.text,password:password.text,displayName:name.text))),child:Text(l.actionCreateAccount))]));}}
