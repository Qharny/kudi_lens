import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// A persistent collection of JSON records keyed by their string id.
/// Records are returned in insertion order.
abstract class RecordStore {
  List<Map<String, dynamic>> readAll();
  Future<void> put(String id, Map<String, dynamic> json);
  Future<void> delete(String id);

  /// Whether the collection has been initialised (seeded) before. Lets a
  /// fresh install be told apart from a user who deleted every record.
  bool get isInitialised;
  Future<void> markInitialised();
}

/// Non-persistent store used by tests and when no storage has been opened.
class InMemoryRecordStore implements RecordStore {
  final Map<String, Map<String, dynamic>> _records = {};
  bool _initialised = false;

  @override
  List<Map<String, dynamic>> readAll() => _records.values.toList();

  @override
  Future<void> put(String id, Map<String, dynamic> json) async =>
      _records[id] = json;

  @override
  Future<void> delete(String id) async => _records.remove(id);

  @override
  bool get isInitialised => _initialised;

  @override
  Future<void> markInitialised() async => _initialised = true;
}

/// Encrypted Hive box storing each record as a JSON string under an
/// auto-increment int key, which keeps insertion order stable.
class HiveRecordStore implements RecordStore {
  final Box<String> _box;
  final Box<bool> _meta;
  final Map<String, int> _keyById = {};

  HiveRecordStore._(this._box, this._meta) {
    for (final key in _box.keys) {
      final json = jsonDecode(_box.get(key)!) as Map<String, dynamic>;
      _keyById[json['id'] as String] = key as int;
    }
  }

  @override
  List<Map<String, dynamic>> readAll() => [
        for (final value in _box.values)
          jsonDecode(value) as Map<String, dynamic>,
      ];

  @override
  Future<void> put(String id, Map<String, dynamic> json) async {
    final encoded = jsonEncode(json);
    final key = _keyById[id];
    if (key == null) {
      _keyById[id] = await _box.add(encoded);
    } else {
      await _box.put(key, encoded);
    }
  }

  @override
  Future<void> delete(String id) async {
    final key = _keyById.remove(id);
    if (key != null) await _box.delete(key);
  }

  @override
  bool get isInitialised => _meta.get(_box.name) ?? false;

  @override
  Future<void> markInitialised() => _meta.put(_box.name, true);
}

/// The record stores backing each feature's data.
class AppStorage {
  final RecordStore transactions;
  final RecordStore pendingAlerts;
  final RecordStore accounts;
  final RecordStore rules;

  const AppStorage({
    required this.transactions,
    required this.pendingAlerts,
    required this.accounts,
    required this.rules,
  });

  factory AppStorage.inMemory() => AppStorage(
        transactions: InMemoryRecordStore(),
        pendingAlerts: InMemoryRecordStore(),
        accounts: InMemoryRecordStore(),
        rules: InMemoryRecordStore(),
      );

  static const _encryptionKeyName = 'kudi_lens_hive_key';

  /// Opens the encrypted on-device boxes. The AES key is generated on first
  /// launch and kept in the platform keystore/keychain.
  static Future<AppStorage> open() async {
    await Hive.initFlutter();

    const secureStorage = FlutterSecureStorage();
    var encodedKey = await secureStorage.read(key: _encryptionKeyName);
    if (encodedKey == null) {
      encodedKey = base64UrlEncode(Hive.generateSecureKey());
      await secureStorage.write(key: _encryptionKeyName, value: encodedKey);
    }
    final cipher = HiveAesCipher(base64Url.decode(encodedKey));

    final meta = await Hive.openBox<bool>('meta');
    Future<RecordStore> openStore(String name) async => HiveRecordStore._(
          await Hive.openBox<String>(name, encryptionCipher: cipher),
          meta,
        );

    return AppStorage(
      transactions: await openStore('transactions'),
      pendingAlerts: await openStore('pending_alerts'),
      accounts: await openStore('accounts'),
      rules: await openStore('rules'),
    );
  }
}

/// Overridden in `main` with the opened on-device storage.
final appStorageProvider = Provider<AppStorage>((ref) => AppStorage.inMemory());

/// Sample data is seeded only in debug builds; release installs start empty.
List<T> debugSeed<T>(List<T> sample) => kDebugMode ? sample : const [];
