import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/unrecognised_alert.dart';
import '../../../core/storage/persisted_list_notifier.dart';
import '../../../core/storage/record_store.dart';

class UnrecognisedAlertsNotifier extends PersistedListNotifier<UnrecognisedAlert> {
  UnrecognisedAlertsNotifier(RecordStore store)
      : super(
          store: store,
          seed: debugSeed(_initialAlerts),
          idOf: (item) => item.id,
          toJson: (item) => item.toJson(),
          fromJson: UnrecognisedAlert.fromJson,
          sortOnLoad: (a, b) => b.receivedAt.compareTo(a.receivedAt),
        );

  static final List<UnrecognisedAlert> _initialAlerts = [
    UnrecognisedAlert(
      id: 'unrecognised_fidelity',
      sender: 'FidelityBank',
      receivedAt: DateTime.now().subtract(const Duration(days: 2)),
      rawMessage:
          'Debit: GHS 120.00 on A/C **8912. Trans: ATM WDL TARKWA. Avail Bal: GHS 540.20. Date: 24/10/2026.',
    ),
    UnrecognisedAlert(
      id: 'unrecognised_gcb',
      sender: 'GCB Alert',
      receivedAt: DateTime.now().subtract(const Duration(days: 4)),
      rawMessage:
          'Dear Customer, your Acct 204***112 was debited with GHS 50.00 for E-Levy charges. Bal: GHS 312.10.',
    ),
  ];

  /// Adds [alert] unless the same message is already stored (re-posted
  /// notifications deliver the same text more than once).
  void add(UnrecognisedAlert alert) {
    if (state.any((a) => a.rawMessage == alert.rawMessage)) return;
    state = [alert, ...state];
  }

  void delete(String id) {
    state = state.where((a) => a.id != id).toList();
  }
}

final unrecognisedAlertsProvider =
    StateNotifierProvider<UnrecognisedAlertsNotifier, List<UnrecognisedAlert>>((ref) {
  return UnrecognisedAlertsNotifier(ref.watch(appStorageProvider).unrecognisedAlerts);
});
