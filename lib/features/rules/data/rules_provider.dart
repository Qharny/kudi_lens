import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/rule.dart';
import '../../../core/storage/persisted_list_notifier.dart';
import '../../../core/storage/record_store.dart';
import '../../../core/models/transaction.dart';

class RulesNotifier extends PersistedListNotifier<CategorizationRule> {
  RulesNotifier(RecordStore store)
      : super(
          store: store,
          seed: debugSeed(_initialRules),
          idOf: (item) => item.id,
          toJson: (item) => item.toJson(),
          fromJson: CategorizationRule.fromJson,
        );

  static final List<CategorizationRule> _initialRules = [
    const CategorizationRule(
      id: 'rule_1',
      matchType: 'narration',
      matchValue: 'SHOPRITE',
      category: 'Food & Dining',
      type: TransactionType.expense,
      confirmations: 5,
      autoConfirm: true,
    ),
    const CategorizationRule(
      id: 'rule_2',
      matchType: 'narration',
      matchValue: 'TOTAL',
      category: 'Transport',
      type: TransactionType.expense,
      confirmations: 4,
      autoConfirm: true,
    ),
    const CategorizationRule(
      id: 'rule_3',
      matchType: 'narration',
      matchValue: 'Transfer Charges',
      category: 'Bank Fees',
      type: TransactionType.fee,
      confirmations: 12,
      autoConfirm: true,
    ),
    const CategorizationRule(
      id: 'rule_4',
      matchType: 'narration',
      matchValue: 'MTN Pull',
      category: 'Transfers',
      type: TransactionType.transfer,
      confirmations: 8,
      autoConfirm: true,
    ),
    const CategorizationRule(
      id: 'rule_5',
      matchType: 'recipient',
      matchValue: 'Kofi Mensah',
      category: 'Rent & Housing',
      type: TransactionType.expense,
      confirmations: 2,
      autoConfirm: false,
    ),
  ];

  void addRule(CategorizationRule rule) {
    state = [...state, rule];
  }

  void updateRule(CategorizationRule updated) {
    state = [
      for (final rule in state)
        if (rule.id == updated.id) updated else rule,
    ];
  }

  void deleteRule(String id) {
    state = state.where((rule) => rule.id != id).toList();
  }

  void toggleAutoConfirm(String id) {
    state = [
      for (final rule in state)
        if (rule.id == id)
          rule.copyWith(autoConfirm: !rule.autoConfirm)
        else
          rule,
    ];
  }
}

final rulesProvider =
    StateNotifierProvider<RulesNotifier, List<CategorizationRule>>((ref) {
  return RulesNotifier(ref.watch(appStorageProvider).rules);
});
