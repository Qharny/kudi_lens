import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/account.dart';

class AccountNotifier extends StateNotifier<List<Account>> {
  AccountNotifier() : super(_initialAccounts);

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
}

final accountProvider = StateNotifierProvider<AccountNotifier, List<Account>>((ref) {
  return AccountNotifier();
});

final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountProvider);
  return accounts.fold(0.0, (sum, acc) => sum + acc.lastBalance);
});
