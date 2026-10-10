import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The key the database is encrypted with, and which database file it opens.
///
/// The generation exists because of one unrecoverable situation. The key lives
/// in the platform keystore and the data lives in a file. An operating system
/// upgrade or a restored backup can take the keystore entry while leaving the
/// file behind, and a file encrypted with a key nobody holds any more cannot
/// be read by us, by the person, or by anybody else. Reusing the same filename
/// would mean every launch failing to open it forever. A new generation starts
/// a new file beside it instead, so the app comes back.
class DatabaseKey {
  const DatabaseKey({required this.generation, required this.hex});

  /// Reads back what [stored] wrote, or null if there is nothing usable.
  ///
  /// A bare 64 character key is what earlier versions wrote, before any of
  /// this existed. That is generation zero and must keep opening the file it
  /// has always opened.
  static DatabaseKey? parse(String? value) {
    if (value == null) return null;
    if (!value.contains(':')) {
      return _isKey(value) ? DatabaseKey(generation: 0, hex: value) : null;
    }
    final separator = value.indexOf(':');
    final generation = int.tryParse(value.substring(0, separator));
    final hex = value.substring(separator + 1);
    if (generation == null || generation < 0 || !_isKey(hex)) return null;
    return DatabaseKey(generation: generation, hex: hex);
  }

  static bool _isKey(String value) =>
      value.length == 64 && RegExp(r'^[0-9a-f]{64}$').hasMatch(value);

  final int generation;
  final String hex;

  String get stored => '$generation:$hex';

  String get databaseName =>
      generation == 0 ? 'habitwise_private' : 'habitwise_private_g$generation';
}

class DatabaseKeyStore {
  const DatabaseKeyStore(this._storage);

  static const _keyName = 'habitwise.database.key.v1';
  final FlutterSecureStorage _storage;

  /// The existing key, or a new one.
  ///
  /// Reading the keystore can throw rather than return nothing: an entry can
  /// survive in a state the platform can no longer decrypt, which is reported
  /// as an error on every read from then on. Left alone that would mean an app
  /// that never opens again, so a read that fails clears the entry and starts
  /// over. That costs the old data, which was unreadable either way.
  Future<DatabaseKey> getOrCreate() async {
    String? value;
    try {
      value = await _storage.read(key: _keyName);
    } on Object {
      try {
        await _storage.delete(key: _keyName);
      } on Object {
        // Nothing left to try. A fresh key is written below regardless.
      }
    }
    final existing = DatabaseKey.parse(value);
    if (existing != null) return existing;
    return _write(DatabaseKey(generation: 0, hex: _randomHex()));
  }

  /// Move to a new file, because the current one cannot be opened with any key
  /// we still have.
  Future<DatabaseKey> nextGeneration(DatabaseKey current) => _write(
    DatabaseKey(generation: current.generation + 1, hex: _randomHex()),
  );

  Future<void> delete() => _storage.delete(key: _keyName);

  Future<DatabaseKey> _write(DatabaseKey key) async {
    await _storage.write(key: _keyName, value: key.stored);
    return key;
  }

  String _randomHex() {
    final random = Random.secure();
    return List<int>.generate(
      32,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
