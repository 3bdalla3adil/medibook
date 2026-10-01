import 'package:flutter/material.dart';
import '../../core/storage/boxes.dart';
import '../../core/storage/local_store.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController(this._store);
  static const _box=Boxes.meta;
  static const _themeKey='settings.theme_mode';
  static const _localeKey='settings.locale';
  static const _notificationsKey='settings.notifications';
  static const _biometricsKey='settings.biometrics';
  final LocalStore _store;
  ThemeMode _themeMode=ThemeMode.system;
  Locale _locale=const Locale('ar');
  bool _notifications=true;
  bool _biometrics=false;
  ThemeMode get themeMode=>_themeMode;
  Locale get locale=>_locale;
  bool get notificationsEnabled=>_notifications;
  bool get biometricsEnabled=>_biometrics;
  Future<void> load() async {
    final theme=await _store.read<String>(_box,_themeKey);
    final locale=await _store.read<String>(_box,_localeKey);
    final notifications=await _store.read<bool>(_box,_notificationsKey);
    final biometrics=await _store.read<bool>(_box,_biometricsKey);
    _themeMode=switch(theme){'light'=>ThemeMode.light,'dark'=>ThemeMode.dark,_=>ThemeMode.system};
    _locale=locale=='en'?const Locale('en'):const Locale('ar');
    _notifications=notifications??true;
    _biometrics=biometrics??false;
    notifyListeners();
  }
  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode=value;
    await _store.write(_box,_themeKey,switch(value){ThemeMode.light=>'light',ThemeMode.dark=>'dark',_=>'system'});
    notifyListeners();
  }
  Future<void> setLocale(Locale value) async {
    _locale=value.languageCode=='en'?const Locale('en'):const Locale('ar');
    await _store.write(_box,_localeKey,_locale.languageCode);
    notifyListeners();
  }
  Future<void> setNotifications(bool value) async {_notifications=value;await _store.write(_box,_notificationsKey,value);notifyListeners();}
  Future<void> setBiometrics(bool value) async {_biometrics=value;await _store.write(_box,_biometricsKey,value);notifyListeners();}
}
