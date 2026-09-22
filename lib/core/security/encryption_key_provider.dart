import 'dart:convert';
import 'dart:math';

import 'secure_storage.dart';

class EncryptionKeyProvider {
  EncryptionKeyProvider(this._storage);

  static const _keyName = 'db.encryption.key.v1';

  final SecureStorage _storage;

  Future<List<int>> getOrCreateKey() async {
    final existing = await _storage.read(_keyName);
    if (existing != null) {
      final bytes = base64Url.decode(existing);
      if (bytes.length == 32) return bytes;
    }
    final key = _generate();
    await _storage.write(_keyName, base64Url.encode(key));
    return key;
  }

  static List<int> _generate() {
    final rnd = Random.secure();
    return List<int>.generate(32, (_) => rnd.nextInt(256));
  }

  Future<void> destroy() => _storage.delete(_keyName);
}
