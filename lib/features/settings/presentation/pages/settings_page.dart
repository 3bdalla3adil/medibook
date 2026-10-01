import 'package:flutter/material.dart';
import '../../../../app/settings/app_settings_controller.dart';
import '../../../../core/di/injector.dart';
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
              ListTile(leading:const Icon(Icons.schedule_outlined),title:Text(l.settingsAppointmentRules),subtitle:Text(l.settingsAppointmentRulesDescription),onTap:()=>_info(context,l.settingsAppointmentRules,l.settingsComingSoon)),
              ListTile(leading:const Icon(Icons.meeting_room_outlined),title:Text(l.settingsRoomsDepartments),subtitle:Text(l.settingsRoomsDepartmentsDescription),onTap:()=>_info(context,l.settingsRoomsDepartments,l.settingsComingSoon)),
              ListTile(leading:const Icon(Icons.payments_outlined),title:Text(l.settingsPaymentMethods),subtitle:Text(l.settingsPaymentMethodsDescription),onTap:()=>_info(context,l.settingsPaymentMethods,l.settingsComingSoon)),
            ]),
            _section(context,l.settingsNotificationsSecurity,Icons.security_outlined,[
              SwitchListTile(secondary:const Icon(Icons.notifications_active_outlined),title:Text(l.settingsNotifications),subtitle:Text(l.settingsNotificationsDescription),value:controller.notificationsEnabled,onChanged:controller.setNotifications),
              SwitchListTile(secondary:const Icon(Icons.fingerprint),title:Text(l.settingsBiometrics),subtitle:Text(l.settingsBiometricsDescription),value:controller.biometricsEnabled,onChanged:controller.setBiometrics),
            ]),
            _section(context,l.settingsAdministration,Icons.admin_panel_settings_outlined,[
              ListTile(leading:const Icon(Icons.people_alt_outlined),title:Text(l.settingsUsersRoles),subtitle:Text(l.settingsUsersRolesDescription),onTap:()=>_info(context,l.settingsUsersRoles,l.settingsComingSoon)),
              ListTile(leading:const Icon(Icons.history_outlined),title:Text(l.settingsAuditLog),subtitle:Text(l.settingsAuditLogDescription),onTap:()=>_info(context,l.settingsAuditLog,l.settingsComingSoon)),
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
      RadioListTile(value:ThemeMode.system,groupValue:c.themeMode,title:Text(l.settingsThemeSystem),onChanged:(v)=>Navigator.pop(context,v)),
      RadioListTile(value:ThemeMode.light,groupValue:c.themeMode,title:Text(l.settingsThemeLight),onChanged:(v)=>Navigator.pop(context,v)),
      RadioListTile(value:ThemeMode.dark,groupValue:c.themeMode,title:Text(l.settingsThemeDark),onChanged:(v)=>Navigator.pop(context,v)),
    ])));
    if(v!=null) await c.setThemeMode(v);
  }
  Future<void> _chooseLanguage(BuildContext context,AppSettingsController c) async {
    final l=AppLocalizations.of(context);
    final v=await showModalBottomSheet<Locale>(context:context,builder:(_)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
      RadioListTile(value:const Locale('ar'),groupValue:c.locale,title:Text(l.languageArabic),onChanged:(v)=>Navigator.pop(context,v)),
      RadioListTile(value:const Locale('en'),groupValue:c.locale,title:Text(l.languageEnglish),onChanged:(v)=>Navigator.pop(context,v)),
    ])));
    if(v!=null) await c.setLocale(v);
  }
  void _info(BuildContext context,String title,String message)=>showDialog<void>(context:context,builder:(_)=>AlertDialog(title:Text(title),content:Text(message),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(AppLocalizations.of(context).actionClose))]));
}
