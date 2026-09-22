import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../security/encryption_key_provider.dart';
import '../security/secure_logger.dart';
import 'boxes.dart';
import 'local_store.dart';

class HiveLocalStore implements LocalStore {
  HiveLocalStore(this._keyProvider);

  static const _metaLastUpdatedSuffix = '.__last_updated';

  final EncryptionKeyProvider _keyProvider;
  final _log = SecureLogger('HiveLocalStore');
  final Map<String, Box<String>> _open = {};

  @override
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    final keyBytes = await _keyProvider.getOrCreateKey();
    final cipher = HiveAesCipher(keyBytes);

    const allBoxes = [
      Boxes.appointments,
      Boxes.patients,
      Boxes.doctors,
      Boxes.services,
      Boxes.notifications,
      Boxes.outbox,
      Boxes.meta,
    ];

    for (final name in allBoxes) {
      _open[name] = await Hive.openBox<String>(name, encryptionCipher: cipher);
    }

    _log.info('Local store initialised', data: {'boxes': allBoxes.length});
  }

  Box<String> _box(String name) {
    final box = _open[name];
    if (box == null) {
      throw StateError('Box "$name" is not open. Did init() run?');
    }
    return box;
  }

  @override
  Future<T?> read<T>(String box, String key) async {
    final raw = _box(box).get(key);
    if (raw == null) return null;
    return jsonDecode(raw) as T;
  }

  @override
  Future<void> write<T>(String box, String key, T value) async {
    final b = _box(box);
    await b.put(key, jsonEncode(value));
    await b.put('$key$_metaLastUpdatedSuffix', DateTime.now().toUtc().toIso8601String());
  }

  @override
  Future<void> putAll<T>(String box, Map<String, T> entries) async {
    final b = _box(box);
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = <String, String>{};
    for (final e in entries.entries) {
      payload[e.key] = jsonEncode(e.value);
      payload['${e.key}$_metaLastUpdatedSuffix'] = now;
    }
    await b.putAll(payload);
  }

  @override
  Future<void> delete(String box, String key) async {
    final b = _box(box);
    await b.delete(key);
    await b.delete('$key$_metaLastUpdatedSuffix');
  }

  @override
  Future<List<T>> readAll<T>(String box) async {
    final b = _box(box);
    return b.keys
        .cast<String>()
        .where((k) => !k.endsWith(_metaLastUpdatedSuffix))
        .map((k) => b.get(k))
        .whereType<String>()
        .map((raw) => jsonDecode(raw) as T)
        .toList(growable: false);
  }

  @override
  Future<void> clearBox(String box) => _box(box).clear();

  @override
  Future<void> wipe() async {
    for (final name in Boxes.phiBearing) {
      await _box(name).clear();
    }
    _log.info('PHI-bearing boxes wiped');
  }

  @override
  Future<DateTime?> lastUpdated(String box) async {
    final b = _box(box);
    DateTime? newest;
    for (final k in b.keys.cast<String>()) {
      if (!k.endsWith(_metaLastUpdatedSuffix)) continue;
      final raw = b.get(k);
      if (raw == null) continue;
      final ts = DateTime.tryParse(raw);
      if (ts != null && (newest == null || ts.isAfter(newest))) newest = ts;
    }
    return newest;
  }

  @override
  Future<void> close() async {
    for (final b in _open.values) {
      await b.close();
    }
    _open.clear();
  }
}
