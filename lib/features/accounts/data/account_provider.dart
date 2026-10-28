import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/account.dart';
import '../../../core/storage/persisted_list_notifier.dart';
import '../../../core/storage/record_store.dart';

class AccountNotifier extends PersistedListNotifier<Account> {
  AccountNotifier(RecordStore store)
      : super(
          store: store,
          seed: debugSeed(_initialAccounts),
          idOf: (item) => item.id,
          toJson: (item) => item.toJson(),
          fromJson: Account.fromJson,
        );

  static final List<Account> _initialAccounts = [
    Account(
      id: 'acc_calbank',
      name: 'CalBank Current',
      provider: 'calbank',
      maskedNumber: '140*******721',
      lastBalance: 268.42,
      lastBalanceDate: DateTime.now().subtract(const Duration(hours: 3)),
      isDefault: true,
    ),
    Account(
      id: 'acc_gcb',
      name: 'GCB Bank Savings',
      provider: 'gcb',
      maskedNumber: '101*******402',
      lastBalance: 1420.00,
      lastBalanceDate: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Account(
      id: 'acc_ecobank',
      name: 'Ecobank Current',
      provider: 'ecobank',
      maskedNumber: '144*******319',
      lastBalance: 850.50,
      lastBalanceDate: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Account(
      id: 'acc_mtn_momo',
      name: 'MTN MoMo Wallet',
      provider: 'mtn_momo',
      maskedNumber: '024*******89',
      lastBalance: 450.00,
      lastBalanceDate: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Account(
      id: 'acc_cash',
      name: 'Cash in Hand',
      provider: 'cash',
      maskedNumber: 'Cash',
      lastBalance: 120.00,
      lastBalanceDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void addAccount(Account account) {
    state = [...state, account];
  }

  /// Replaces the account with the same id, or adds it if new.
  void upsertAccount(Account account) {
    final exists = state.any((acc) => acc.id == account.id);
    state = exists
        ? [for (final acc in state) acc.id == account.id ? account : acc]
        : [...state, account];
  }

  void updateBalance(String accountId, double newBalance) {
    state = [
      for (final acc in state)
        if (acc.id == accountId)
          acc.copyWith(
            lastBalance: newBalance,
            lastBalanceDate: DateTime.now(),
          )
        else
          acc,
    ];
  }

  void setDefaultAccount(String accountId) {
    state = [
      for (final acc in state)
        acc.copyWith(isDefault: acc.id == accountId),
    ];
  }

  void deleteAccount(String accountId) {
    state = state.where((acc) => acc.id != accountId).toList();
  }
}

final accountProvider = StateNotifierProvider<AccountNotifier, List<Account>>((ref) {
  return AccountNotifier(ref.watch(appStorageProvider).accounts);
});

final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountProvider);
  return accounts.fold(0.0, (sum, acc) => sum + acc.lastBalance);
});
