import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/storage/boxes.dart';
import '../../core/storage/local_store.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController(this._store);

  static const _box = Boxes.meta;
  static const _themeKey = 'settings.theme_mode';
  static const _localeKey = 'settings.locale';
  static const _notificationsKey = 'settings.notifications';
  static const _biometricsKey = 'settings.biometrics';
  static const _slotDurationKey = 'settings.slot_duration_minutes';
  static const _advanceBookingDaysKey = 'settings.advance_booking_days';
  static const _cancellationNoticeHoursKey = 'settings.cancellation_notice_hours';
  static const _departmentsKey = 'settings.departments';
  static const _roomsKey = 'settings.rooms';
  static const _paymentMethodsKey = 'settings.payment_methods';

  final LocalStore _store;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar');
  bool _notifications = true;
  bool _biometrics = false;
  int _slotDurationMinutes = 30;
  int _advanceBookingDays = 90;
  int _cancellationNoticeHours = 2;
  List<String> _departments = const ['General Medicine', 'Laboratory'];
  List<String> _rooms = const ['Room 1', 'Room 2'];
  List<String> _paymentMethods = const ['Cash', 'Card'];

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get notificationsEnabled => _notifications;
  bool get biometricsEnabled => _biometrics;
  int get slotDurationMinutes => _slotDurationMinutes;
  int get advanceBookingDays => _advanceBookingDays;
  int get cancellationNoticeHours => _cancellationNoticeHours;
  List<String> get departments => List.unmodifiable(_departments);
  List<String> get rooms => List.unmodifiable(_rooms);
  List<String> get paymentMethods => List.unmodifiable(_paymentMethods);

  Future<void> load() async {
    final theme = await _store.read<String>(_box, _themeKey);
    final locale = await _store.read<String>(_box, _localeKey);
    final notifications = await _store.read<bool>(_box, _notificationsKey);
    final biometrics = await _store.read<bool>(_box, _biometricsKey);
    final slotDuration = await _store.read<int>(_box, _slotDurationKey);
    final advanceDays = await _store.read<int>(_box, _advanceBookingDaysKey);
    final cancellationHours = await _store.read<int>(_box, _cancellationNoticeHoursKey);
    final departments = await _readList(_departmentsKey);
    final rooms = await _readList(_roomsKey);
    final paymentMethods = await _readList(_paymentMethodsKey);

    _themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _locale = locale == 'en' ? const Locale('en') : const Locale('ar');
    _notifications = notifications ?? true;
    _biometrics = biometrics ?? false;
    _slotDurationMinutes = _validInt(slotDuration, 30, 5, 240);
    _advanceBookingDays = _validInt(advanceDays, 90, 1, 365);
    _cancellationNoticeHours = _validInt(cancellationHours, 2, 0, 168);
    _departments = departments.isEmpty ? _departments : departments;
    _rooms = rooms.isEmpty ? _rooms : rooms;
    _paymentMethods = paymentMethods.isEmpty ? _paymentMethods : paymentMethods;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    await _store.write(
      _box,
      _themeKey,
      switch (value) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      },
    );
    notifyListeners();
  }

  Future<void> setLocale(Locale value) async {
    _locale = value.languageCode == 'en' ? const Locale('en') : const Locale('ar');
    await _store.write(_box, _localeKey, _locale.languageCode);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _notifications = value;
    await _store.write(_box, _notificationsKey, value);
    notifyListeners();
  }

  Future<void> setBiometrics(bool value) async {
    _biometrics = value;
    await _store.write(_box, _biometricsKey, value);
    notifyListeners();
  }

  Future<void> setAppointmentRules({
    required int slotDurationMinutes,
    required int advanceBookingDays,
    required int cancellationNoticeHours,
  }) async {
    _slotDurationMinutes = _validInt(slotDurationMinutes, 30, 5, 240);
    _advanceBookingDays = _validInt(advanceBookingDays, 90, 1, 365);
    _cancellationNoticeHours = _validInt(cancellationNoticeHours, 2, 0, 168);
    await _store.putAll(_box, {
      _slotDurationKey: _slotDurationMinutes,
      _advanceBookingDaysKey: _advanceBookingDays,
      _cancellationNoticeHoursKey: _cancellationNoticeHours,
    });
    notifyListeners();
  }

  Future<void> setDepartments(List<String> values) async {
    _departments = _clean(values);
    await _writeList(_departmentsKey, _departments);
    notifyListeners();
  }

  Future<void> setRooms(List<String> values) async {
    _rooms = _clean(values);
    await _writeList(_roomsKey, _rooms);
    notifyListeners();
  }

  Future<void> setPaymentMethods(List<String> values) async {
    _paymentMethods = _clean(values);
    await _writeList(_paymentMethodsKey, _paymentMethods);
    notifyListeners();
  }

  Future<List<String>> _readList(String key) async {
    final raw = await _store.read<String>(_box, key);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      }
    } catch (_) {
      // Corrupt settings are ignored and replaced by safe defaults.
    }
    return const [];
  }

  Future<void> _writeList(String key, List<String> values) =>
      _store.write(_box, key, jsonEncode(values));

  List<String> _clean(List<String> values) => values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList(growable: false);

  int _validInt(int? value, int fallback, int min, int max) =>
      value == null || value < min || value > max ? fallback : value;
}
