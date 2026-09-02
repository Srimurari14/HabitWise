import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseKeyStore {
  const DatabaseKeyStore(this._storage);

  static const _keyName = 'habitwise.database.key.v1';
  final FlutterSecureStorage _storage;

  Future<String> getOrCreate() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.length == 64) return existing;
    final random = Random.secure();
    final key = List<int>.generate(
      32,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: _keyName, value: key);
    return key;
  }

  Future<void> delete() => _storage.delete(key: _keyName);
}
