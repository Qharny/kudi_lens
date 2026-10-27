import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/transaction.dart';
import '../../../core/storage/persisted_list_notifier.dart';
import '../../../core/storage/record_store.dart';

const _uuid = Uuid();

class TransactionNotifier extends PersistedListNotifier<TransactionItem> {
  TransactionNotifier(RecordStore store)
      : super(
          store: store,
          seed: debugSeed(_initialTransactions),
          idOf: (item) => item.id,
          toJson: (item) => item.toJson(),
          fromJson: TransactionItem.fromJson,
          sortOnLoad: (a, b) => b.date.compareTo(a.date),
        );

  static final List<TransactionItem> _initialTransactions = [
    TransactionItem(
      id: 'tx_1',
      amount: 145.00,
      currency: 'GHS',
      type: TransactionType.expense,
      category: 'Food & Dining',
      merchant: 'Shoprite Tarkwa',
      note: 'Weekly household groceries',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      source: TransactionSource.bankAlert,
      status: TransactionStatus.confirmed,
      accountId: 'acc_calbank',
      narration: 'POS Purchase SHOPRITE TARKWA',
      location: 'Tarkwa',
      balanceAfter: 268.42,
    ),
    TransactionItem(
      id: 'tx_2',
      amount: 2.00,
      currency: 'GHS',
      type: TransactionType.fee,
      category: 'Bank Fees',
      merchant: 'CalBank',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      source: TransactionSource.bankAlert,
      status: TransactionStatus.confirmed,
      accountId: 'acc_calbank',
      narration: 'Transfer Charges',
      location: '@BNK',
      balanceAfter: 413.42,
    ),
    TransactionItem(
      id: 'tx_3',
      amount: 30.00,
      currency: 'GHS',
      type: TransactionType.transfer,
      category: 'Transfers',
      merchant: 'MTN MoMo Pull',
      date: DateTime.now().subtract(const Duration(hours: 5, minutes: 2)),
      source: TransactionSource.bankAlert,
      status: TransactionStatus.confirmed,
      accountId: 'acc_calbank',
      narration: 'CalPay MTN Pull Txn..',
      location: 'Tarkwa',
      balanceAfter: 415.42,
      linkedTransactionId: 'tx_momo_credit_1',
    ),
    TransactionItem(
      id: 'tx_4',
      amount: 45.00,
      currency: 'GHS',
      type: TransactionType.expense,
      category: 'Transport',
      merchant: 'Total Filling Station',
      note: 'Fuel for car',
      date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      source: TransactionSource.bankAlert,
      status: TransactionStatus.confirmed,
      accountId: 'acc_mtn_momo',
      narration: 'Payment to TOTAL TARKWA',
      balanceAfter: 450.00,
    ),
    TransactionItem(
      id: 'tx_5',
      amount: 15.00,
      currency: 'GHS',
      type: TransactionType.expense,
      category: 'Data & Airtime',
      merchant: 'MTN Airtime',
      date: DateTime.now().subtract(const Duration(days: 2)),
      source: TransactionSource.manual,
      status: TransactionStatus.confirmed,
      accountId: 'acc_mtn_momo',
      balanceAfter: 495.00,
    ),
    TransactionItem(
      id: 'tx_gcb_1',
      amount: 320.00,
      currency: 'GHS',
      type: TransactionType.expense,
      category: 'Shopping',
      merchant: 'Game Stores Accra',
      note: 'Office accessories and electronics',
      date: DateTime.now().subtract(const Duration(days: 1)),
      source: TransactionSource.bankAlert,
      status: TransactionStatus.confirmed,
      accountId: 'acc_gcb',
      narration: 'POS PURCHASE GAME ACCRA',
      location: 'Accra Mall',
      balanceAfter: 1420.00,
    ),
    TransactionItem(
      id: 'tx_eco_1',
      amount: 85.00,
      currency: 'GHS',
      type: TransactionType.expense,
      category: 'Health & Medical',
      merchant: 'Ernest Chemists',
      note: 'Vitamins & first-aid refill',
      date: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      source: TransactionSource.bankAlert,
      status: TransactionStatus.confirmed,
      accountId: 'acc_ecobank',
      narration: 'POS ERNEST CHEMISTS OSU',
      location: 'Osu, Accra',
      balanceAfter: 850.50,
    ),
    TransactionItem(
      id: 'tx_gcb_salary',
      amount: 2500.00,
      currency: 'GHS',
      type: TransactionType.income,
      category: 'Salary & Income',
      merchant: 'Employer Direct Credit',
      note: 'Monthly salary disbursement',
      date: DateTime.now().subtract(const Duration(days: 5)),
      isIncome: true,
      source: TransactionSource.bankAlert,
      status: TransactionStatus.confirmed,
      accountId: 'acc_gcb',
      narration: 'SALARY OCTOBER 2026',
      balanceAfter: 1740.00,
    ),
    TransactionItem(
      id: 'tx_6',
      amount: 850.00,
      currency: 'GHS',
      type: TransactionType.income,
      category: 'Salary & Income',
      merchant: 'Client Direct Transfer',
      note: 'Mobile App Freelance Milestone',
      date: DateTime.now().subtract(const Duration(days: 4)),
      isIncome: true,
      source: TransactionSource.manual,
      status: TransactionStatus.confirmed,
      accountId: 'acc_calbank',
    ),
  ];

  void addTransaction(TransactionItem transaction) {
    state = [transaction, ...state];
  }

  void updateTransaction(TransactionItem updated) {
    state = [
      for (final tx in state)
        if (tx.id == updated.id) updated else tx,
    ];
  }

  void deleteTransaction(String id) {
    state = state.where((tx) => tx.id != id).toList();
  }

  void quickAdd({
    required double amount,
    required TransactionType type,
    required String category,
    String? accountId,
    String? merchant,
    String? note,
  }) {
    final newTx = TransactionItem(
      id: _uuid.v4(),
      amount: amount,
      currency: 'GHS',
      type: type,
      category: category,
      merchant: merchant,
      note: note,
      date: DateTime.now(),
      isIncome: type == TransactionType.income,
      source: TransactionSource.manual,
      status: TransactionStatus.confirmed,
      accountId: accountId,
    );
    addTransaction(newTx);
  }
}

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<TransactionItem>>((ref) {
  return TransactionNotifier(ref.watch(appStorageProvider).transactions);
});

final recentTransactionsProvider = Provider<List<TransactionItem>>((ref) {
  final txs = ref.watch(transactionProvider);
  final sorted = [...txs]..sort((a, b) => b.date.compareTo(a.date));
  return sorted;
});

final todaySpendingProvider = Provider<double>((ref) {
  final txs = ref.watch(transactionProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return txs.where((tx) {
    final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
    return txDate == today &&
        (tx.type == TransactionType.expense || tx.type == TransactionType.fee);
  }).fold(0.0, (sum, tx) => sum + tx.amount);
});

final periodSpendingProvider = Provider.family<double, int>((ref, days) {
  final txs = ref.watch(transactionProvider);
  final cutoff = DateTime.now().subtract(Duration(days: days));

  return txs.where((tx) {
    return tx.date.isAfter(cutoff) &&
        (tx.type == TransactionType.expense || tx.type == TransactionType.fee);
  }).fold(0.0, (sum, tx) => sum + tx.amount);
});

final totalIncomeProvider = Provider<double>((ref) {
  final txs = ref.watch(transactionProvider);
  return txs
      .where((tx) => tx.type == TransactionType.income)
      .fold(0.0, (sum, tx) => sum + tx.amount);
});

final totalBankFeesProvider = Provider<double>((ref) {
  final txs = ref.watch(transactionProvider);
  return txs
      .where((tx) => tx.type == TransactionType.fee)
      .fold(0.0, (sum, tx) => sum + tx.amount);
});

final totalTransfersProvider = Provider<double>((ref) {
  final txs = ref.watch(transactionProvider);
  return txs
      .where((tx) => tx.type == TransactionType.transfer)
      .fold(0.0, (sum, tx) => sum + tx.amount);
});
