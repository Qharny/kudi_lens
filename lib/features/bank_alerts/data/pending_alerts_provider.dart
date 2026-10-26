import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/transaction.dart';
import '../../transactions/data/transaction_provider.dart';

class PendingAlertNotifier extends StateNotifier<List<TransactionItem>> {
  final Ref _ref;

  PendingAlertNotifier(this._ref) : super(_initialPendingAlerts);

  static final List<TransactionItem> _initialPendingAlerts = [
    TransactionItem(
      id: 'pending_alert_gcb',
      amount: 240.00,
      currency: 'GHS',
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(minutes: 12)),
      source: TransactionSource.bankAlert,
      status: TransactionStatus.pending,
      accountId: 'acc_gcb',
      narration: 'POS CHOP BAR OSU',
      location: 'Osu, Accra',
      balanceAfter: 1180.00,
      rawMessage:
          'Acc: 101*******402 debited with GHS 240.00 on 26 OCT 2026. Info: POS CHOP BAR OSU. Avail Bal: GHS 1,180.00.',
    ),
    TransactionItem(
      id: 'pending_alert_ecobank',
      amount: 95.00,
      currency: 'GHS',
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(minutes: 45)),
      source: TransactionSource.bankAlert,
      status: TransactionStatus.pending,
      accountId: 'acc_ecobank',
      narration: 'TOTAL AIRPORT ACCRA',
      location: 'Airport, Accra',
      balanceAfter: 755.50,
      rawMessage:
          'ECOBANK: Dr GHS 95.00 from A/c 144*******319 at TOTAL AIRPORT on 26-OCT-2026. Avail Bal GHS 755.50.',
    ),
    TransactionItem(
      id: 'pending_alert_calbank',
      amount: 180.00,
      currency: 'GHS',
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      source: TransactionSource.bankAlert,
      status: TransactionStatus.pending,
      accountId: 'acc_calbank',
      narration: 'POS Purchase MELCOM TARKWA',
      location: 'Tarkwa',
      balanceAfter: 88.42,
      rawMessage:
          'A/C No.: 140*******721 has been debited with GHS 180.00 on 26 OCT 2026 Tarkwa. Info: POS Purchase MELCOM TARKWA.. Avail. bal: GHS 88.42. Thank you.',
    ),
    TransactionItem(
      id: 'pending_alert_momo',
      amount: 35.00,
      currency: 'GHS',
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(hours: 4)),
      source: TransactionSource.bankAlert,
      status: TransactionStatus.pending,
      accountId: 'acc_mtn_momo',
      narration: 'Payment to 0551234567',
      balanceAfter: 415.00,
      rawMessage:
          'Payment made for GHS 35.00 to 0551234567. Current Balance: GHS 415.00. Reference: Lunch. Fee was GHS 0.00.',
    ),
  ];

  void dismissAlert(String alertId) {
    state = state.where((item) => item.id != alertId).toList();
  }

  void categorizeAndConfirm({
    required String alertId,
    required String category,
    required TransactionType type,
    String? merchant,
    String? note,
  }) {
    final alert = state.firstWhere((item) => item.id == alertId);
    final confirmed = alert.copyWith(
      status: TransactionStatus.confirmed,
      category: category,
      type: type,
      merchant: merchant ?? alert.merchant,
      note: note ?? alert.note,
    );

    // Remove from pending
    state = state.where((item) => item.id != alertId).toList();

    // Add to transaction repository
    _ref.read(transactionProvider.notifier).addTransaction(confirmed);
  }
}

final pendingAlertsProvider =
    StateNotifierProvider<PendingAlertNotifier, List<TransactionItem>>((ref) {
  return PendingAlertNotifier(ref);
});

final pendingAlertsCountProvider = Provider<int>((ref) {
  final pending = ref.watch(pendingAlertsProvider);
  return pending.length;
});
