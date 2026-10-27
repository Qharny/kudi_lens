import 'package:flutter_test/flutter_test.dart';
import 'package:kudi_lens/core/models/account.dart';
import 'package:kudi_lens/core/models/rule.dart';
import 'package:kudi_lens/core/models/transaction.dart';
import 'package:kudi_lens/core/storage/record_store.dart';
import 'package:kudi_lens/features/accounts/data/account_provider.dart';
import 'package:kudi_lens/features/transactions/data/transaction_provider.dart';

void main() {
  group('model JSON round-trip', () {
    test('TransactionItem keeps every field', () {
      final tx = TransactionItem(
        id: 'tx',
        amount: 30,
        type: TransactionType.transfer,
        category: 'Transfers',
        note: 'n',
        date: DateTime(2026, 7, 21, 9, 30),
        source: TransactionSource.bankAlert,
        status: TransactionStatus.pending,
        accountId: 'acc',
        merchant: 'm',
        narration: 'CalPay MTN Pull Txn',
        location: 'Tarkwa',
        balanceAfter: 10.43,
        rawMessage: 'raw',
        messageHash: 'hash',
        linkedTransactionId: 'linked',
        ruleId: 'rule',
      );
      expect(TransactionItem.fromJson(tx.toJson()).toJson(), tx.toJson());
    });

    test('Account and CategorizationRule keep every field', () {
      final acc = Account(
        id: 'a',
        name: 'CalBank',
        provider: 'calbank',
        maskedNumber: '140***721',
        lastBalance: 268.42,
        lastBalanceDate: DateTime(2026, 10, 1),
        isDefault: true,
      );
      expect(Account.fromJson(acc.toJson()).toJson(), acc.toJson());

      const rule = CategorizationRule(
        id: 'r',
        matchType: 'narration',
        matchValue: 'SHOPRITE',
        category: 'Food & Dining',
        type: TransactionType.expense,
        confirmations: 3,
        autoConfirm: true,
      );
      expect(CategorizationRule.fromJson(rule.toJson()).toJson(), rule.toJson());
    });
  });

  group('PersistedListNotifier', () {
    test('seeds once, then reloads persisted changes instead of the seed', () async {
      final store = InMemoryRecordStore();
      final first = TransactionNotifier(store);
      final seeded = first.state.length;
      expect(seeded, greaterThan(0));

      first.deleteTransaction(first.state.first.id);
      first.quickAdd(amount: 12.5, type: TransactionType.expense, category: 'Transport');
      await pumpEventQueue();

      final reloaded = TransactionNotifier(store);
      expect(reloaded.state.length, seeded);
      expect(reloaded.state.any((tx) => tx.amount == 12.5), isTrue);
    });

    test('deleting every record does not bring the seed back', () async {
      final store = InMemoryRecordStore();
      final first = AccountNotifier(store);
      for (final acc in [...first.state]) {
        first.deleteAccount(acc.id);
      }
      await pumpEventQueue();

      expect(AccountNotifier(store).state, isEmpty);
    });

    test('updates are written back', () async {
      final store = InMemoryRecordStore();
      final first = AccountNotifier(store);
      final id = first.state.last.id;
      first.updateBalance(id, 999);
      first.setDefaultAccount(id);
      await pumpEventQueue();

      final acc = AccountNotifier(store).state.firstWhere((a) => a.id == id);
      expect(acc.lastBalance, 999);
      expect(acc.isDefault, isTrue);
    });
  });
}
