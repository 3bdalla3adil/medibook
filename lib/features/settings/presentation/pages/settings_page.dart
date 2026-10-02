import 'package:flutter/material.dart';
import '../../../../app/settings/app_settings_controller.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../audit/presentation/pages/audit_log_page.dart';
import '../../../../l10n/gen/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override Widget build(BuildContext context){
    final controller=getIt<AppSettingsController>();
    return AnimatedBuilder(
      animation:controller,
      builder:(context,_){
        final l=AppLocalizations.of(context);
        return Scaffold(
          appBar:AppBar(title:Text(l.settingsTitle)),
          body:ListView(padding:const EdgeInsets.all(16),children:[
            _section(context,l.settingsAppearance,Icons.palette_outlined,[
              ListTile(leading:const Icon(Icons.brightness_auto_outlined),title:Text(l.settingsTheme),subtitle:Text(_themeLabel(l,controller.themeMode)),onTap:()=>_chooseTheme(context,controller)),
              ListTile(leading:const Icon(Icons.language_outlined),title:Text(l.settingsLanguage),subtitle:Text(controller.locale.languageCode=='ar'?l.languageArabic:l.languageEnglish),onTap:()=>_chooseLanguage(context,controller)),
            ]),
            _section(context,l.settingsClinic,Icons.local_hospital_outlined,[
              ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: Text(l.settingsAppointmentRules),
                subtitle: Text(
                  controller.slotDurationMinutes.toString() + ' min · ' +
                  controller.advanceBookingDays.toString() + ' days · ' +
                  controller.cancellationNoticeHours.toString() + 'h',
                ),
                onTap: () => _editAppointmentRules(context, controller),
              ),
              ListTile(
                leading: const Icon(Icons.meeting_room_outlined),
                title: Text(l.settingsRoomsDepartments),
                subtitle: Text(
                  controller.departments.length.toString() + ' departments · ' +
                  controller.rooms.length.toString() + ' rooms',
                ),
                onTap: () => _editRoomsDepartments(context, controller),
              ),
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(l.settingsPaymentMethods),
                subtitle: Text(controller.paymentMethods.join(', ')),
                onTap: () => _editPaymentMethods(context, controller),
              ),
            ]),
            _section(context,l.settingsNotificationsSecurity,Icons.security_outlined,[
              SwitchListTile(secondary:const Icon(Icons.notifications_active_outlined),title:Text(l.settingsNotifications),subtitle:Text(l.settingsNotificationsDescription),value:controller.notificationsEnabled,onChanged:controller.setNotifications),
              SwitchListTile(secondary:const Icon(Icons.fingerprint),title:Text(l.settingsBiometrics),subtitle:Text(l.settingsBiometricsDescription),value:controller.biometricsEnabled,onChanged:(value)=>_setBiometrics(context,controller,value)),
            ]),
            _section(context,l.settingsAdministration,Icons.admin_panel_settings_outlined,[
              ListTile(leading:const Icon(Icons.people_alt_outlined),title:Text(l.settingsUsersRoles),subtitle:Text(l.settingsUsersRolesDescription),onTap:()=>_info(context,l.settingsUsersRoles,l.settingsUsersRolesManaged)),
              ListTile(leading:const Icon(Icons.history_outlined),title:Text(l.settingsAuditLog),subtitle:Text(l.settingsAuditLogDescription),onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const AuditLogPage()))),
            ]),
          ]),
        );
      },
    );
  }
  Widget _section(BuildContext context,String title,IconData icon,List<Widget> children)=>Card(
    margin:const EdgeInsets.only(bottom:16),
    child:Column(children:[ListTile(leading:Icon(icon),title:Text(title,style:Theme.of(context).textTheme.titleMedium)),const Divider(height:1),...children]));
  String _themeLabel(AppLocalizations l,ThemeMode mode)=>switch(mode){ThemeMode.light=>l.settingsThemeLight,ThemeMode.dark=>l.settingsThemeDark,ThemeMode.system=>l.settingsThemeSystem};
  Future<void> _chooseTheme(BuildContext context,AppSettingsController c) async {
    final l=AppLocalizations.of(context);
    final v=await showModalBottomSheet<ThemeMode>(context:context,builder:(_)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
      RadioGroup<ThemeMode>(
        groupValue: c.themeMode,
        onChanged: (v) => Navigator.pop(context, v),
        child: Column(children: [
          RadioListTile(value: ThemeMode.system, title: Text(l.settingsThemeSystem)),
          RadioListTile(value: ThemeMode.light, title: Text(l.settingsThemeLight)),
          RadioListTile(value: ThemeMode.dark, title: Text(l.settingsThemeDark)),
        ]),
      ),
    ])));
    if(v!=null) await c.setThemeMode(v);
  }
  Future<void> _chooseLanguage(BuildContext context,AppSettingsController c) async {
    final l=AppLocalizations.of(context);
    final v=await showModalBottomSheet<Locale>(context:context,builder:(_)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
      RadioGroup<Locale>(
        groupValue: c.locale,
        onChanged: (v) => Navigator.pop(context, v),
        child: Column(children: [
          RadioListTile(value: const Locale('ar'), title: Text(l.languageArabic)),
          RadioListTile(value: const Locale('en'), title: Text(l.languageEnglish)),
        ]),
      ),
    ])));
    if(v!=null) await c.setLocale(v);
  }
  Future<void> _setBiometrics(BuildContext context,AppSettingsController c,bool value) async {
    final l=AppLocalizations.of(context);
    if(value){
      final available=await getIt<BiometricService>().isAvailable();
      if(!available){_info(context,l.settingsBiometrics,l.settingsBiometricsUnavailable);return;}
      final ok=await getIt<BiometricService>().authenticate(reason:l.settingsBiometricsConfirm);
      if(!ok||!context.mounted)return;
    }
    await c.setBiometrics(value);
  }

  Future<void> _editAppointmentRules(BuildContext context,AppSettingsController c) async {
    final l=AppLocalizations.of(context);
    final slot=TextEditingController(text:c.slotDurationMinutes.toString());
    final advance=TextEditingController(text:c.advanceBookingDays.toString());
    final cancel=TextEditingController(text:c.cancellationNoticeHours.toString());
    final key=GlobalKey<FormState>();
    final save=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(
      title:Text(l.settingsAppointmentRules),
      content:Form(key:key,child:Column(mainAxisSize:MainAxisSize.min,children:[
        _numberField(slot,l.settingsSlotDuration,5,240),
        _numberField(advance,l.settingsAdvanceBooking,1,365),
        _numberField(cancel,l.settingsCancellationNotice,0,168),
      ])),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context,false),child:Text(l.actionClose)),
        FilledButton(onPressed:()=>key.currentState!.validate()?Navigator.pop(context,true):null,child:Text(l.actionSave)),
      ],
    ));
    if(save==true)await c.setAppointmentRules(slotDurationMinutes:int.parse(slot.text),advanceBookingDays:int.parse(advance.text),cancellationNoticeHours:int.parse(cancel.text));
    slot.dispose();advance.dispose();cancel.dispose();
  }

  Widget _numberField(TextEditingController c,String label,int min,int max)=>Padding(
    padding:const EdgeInsets.only(bottom:10),
    child:TextFormField(
      controller:c,
      keyboardType:TextInputType.number,
      decoration:InputDecoration(labelText:label),
      validator:(v){final n=int.tryParse(v??'');return n==null||n<min||n>max?min.toString()+'-'+max.toString():null;},
    ),
  );

  Future<void> _editRoomsDepartments(BuildContext context,AppSettingsController c) async {
    final l=AppLocalizations.of(context);
    final value=TextEditingController(text:[...c.departments.map((e)=>'D:'+e),...c.rooms.map((e)=>'R:'+e)].join('\n'));
    final save=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(
      title:Text(l.settingsRoomsDepartments),
      content:TextField(controller:value,minLines:5,maxLines:10,decoration:const InputDecoration(hintText:'D:General Medicine\\nR:Room 1')),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context,false),child:Text(l.actionClose)),
        FilledButton(onPressed:()=>Navigator.pop(context,true),child:Text(l.actionSave)),
      ],
    ));
    if(save==true){
      final departments=<String>[],rooms=<String>[];
      for(final line in value.text.split('\n').map((e)=>e.trim()).where((e)=>e.isNotEmpty)){
        if(line.startsWith('D:'))departments.add(line.substring(2));
        if(line.startsWith('R:'))rooms.add(line.substring(2));
      }
      await c.setDepartments(departments);await c.setRooms(rooms);
    }
    value.dispose();
  }

  Future<void> _editPaymentMethods(BuildContext context,AppSettingsController c) async {
    final l=AppLocalizations.of(context);
    final value=TextEditingController(text:c.paymentMethods.join('\n'));
    final save=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(
      title:Text(l.settingsPaymentMethods),
      content:TextField(controller:value,minLines:4,maxLines:8,decoration:const InputDecoration(hintText:'Cash\\nCard\\nInsurance')),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context,false),child:Text(l.actionClose)),
        FilledButton(onPressed:()=>Navigator.pop(context,true),child:Text(l.actionSave)),
      ],
    ));
    if(save==true)await c.setPaymentMethods(value.text.split('\n'));
    value.dispose();
  }

  void _info(BuildContext context,String title,String message)=>showDialog<void>(context:context,builder:(_)=>AlertDialog(title:Text(title),content:Text(message),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(AppLocalizations.of(context).actionClose))]));
}
