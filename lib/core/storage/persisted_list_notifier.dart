import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'record_store.dart';

/// A list notifier whose state is mirrored into a [RecordStore].
///
/// Subclasses mutate `state` as usual; only records that were added,
/// replaced or removed are written back.
abstract class PersistedListNotifier<T> extends StateNotifier<List<T>> {
  final RecordStore _store;
  final String Function(T) _idOf;
  final Map<String, dynamic> Function(T) _toJson;

  PersistedListNotifier({
    required RecordStore store,
    required List<T> seed,
    required String Function(T) idOf,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
    int Function(T, T)? sortOnLoad,
  })  : _store = store,
        _idOf = idOf,
        _toJson = toJson,
        super(_load(store, seed, idOf, toJson, fromJson, sortOnLoad));

  static List<T> _load<T>(
    RecordStore store,
    List<T> seed,
    String Function(T) idOf,
    Map<String, dynamic> Function(T) toJson,
    T Function(Map<String, dynamic>) fromJson,
    int Function(T, T)? sortOnLoad,
  ) {
    if (!store.isInitialised) {
      for (final item in seed) {
        _report(store.put(idOf(item), toJson(item)));
      }
      _report(store.markInitialised());
      return [...seed];
    }
    final items = store.readAll().map(fromJson).toList();
    if (sortOnLoad != null) items.sort(sortOnLoad);
    return items;
  }

  @override
  set state(List<T> value) {
    final previous = {for (final item in super.state) _idOf(item): item};
    super.state = value;

    for (final item in value) {
      final id = _idOf(item);
      if (!identical(previous.remove(id), item)) {
        _report(_store.put(id, _toJson(item)));
      }
    }
    for (final removedId in previous.keys) {
      _report(_store.delete(removedId));
    }
  }

  static void _report(Future<void> write) {
    write.catchError((Object e, StackTrace st) {
      debugPrint('Failed to persist record: $e\n$st');
    });
  }
}
