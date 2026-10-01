import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/app/settings/app_settings_controller.dart';
import 'package:medibook/core/storage/local_store.dart';

class _MemoryStore implements LocalStore {
  final Map<String,dynamic> data={};
  @override Future<void> init() async {}
  @override Future<void> close() async {}
  @override Future<T?> read<T>(String box,String key) async=>data['$box:$key'] as T?;
  @override Future<void> write<T>(String box,String key,T value) async{data['$box:$key']=value;}
  @override Future<void> delete(String box,String key) async{data.remove('$box:$key');}
  @override Future<List<T>> readAll<T>(String box) async=>[];
  @override Future<void> putAll<T>(String box,Map<String,T> entries) async{entries.forEach((key,value){data['$box:$key']=value;});}
  @override Future<void> clearBox(String box) async{}
  @override Future<void> wipe() async{}
  @override Future<DateTime?> lastUpdated(String box) async=>null;
}
void main(){
  test('settings persist preferences',() async{
    final store=_MemoryStore();
    final settings=AppSettingsController(store);
    await settings.load();
    expect(settings.themeMode,ThemeMode.system);
    expect(settings.locale.languageCode,'ar');
    await settings.setThemeMode(ThemeMode.dark);
    await settings.setLocale(const Locale('en'));
    await settings.setNotifications(false);
    await settings.setBiometrics(true);
    final restored=AppSettingsController(store);
    await restored.load();
    expect(restored.themeMode,ThemeMode.dark);
    expect(restored.locale.languageCode,'en');
    expect(restored.notificationsEnabled,isFalse);
    expect(restored.biometricsEnabled,isTrue);
  });
}
