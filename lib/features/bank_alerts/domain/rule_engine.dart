import '../../../core/models/rule.dart';
import '../../../core/models/transaction.dart';

/// Consistent confirmations after which a rule stops asking (doc.md §11.2).
const autoConfirmThreshold = 3;

/// The most specific rule matching the alert's narration or recipient.
CategorizationRule? findMatchingRule(
  List<CategorizationRule> rules, {
  String? narration,
  String? counterparty,
}) {
  bool matches(CategorizationRule rule) {
    final target = switch (rule.matchType) {
      'narration' => narration,
      'recipient' => counterparty,
      _ => null,
    };
    return target != null &&
        target.toLowerCase().contains(rule.matchValue.toLowerCase());
  }

  final candidates = rules.where(matches).toList()
    ..sort((a, b) {
      final bySpecificity = b.matchValue.length.compareTo(a.matchValue.length);
      return bySpecificity != 0
          ? bySpecificity
          : b.confirmations.compareTo(a.confirmations);
    });
  return candidates.firstOrNull;
}

/// Returns [rules] updated with what the user taught by categorising the
/// alert-sourced [alert] as [category]/[type].
///
/// Agreeing with a rule adds a confirmation and turns on auto-confirm when
/// the threshold is reached; disagreeing resets it to ask again.
List<CategorizationRule> learnFromConfirmation(
  List<CategorizationRule> rules,
  TransactionItem alert, {
  required String category,
  required TransactionType type,
  required String Function() newId,
}) {
  var existing = rules.where((r) => r.id == alert.ruleId).firstOrNull;

  if (existing == null) {
    final (matchType, matchValue) = alert.merchant != null
        ? ('recipient', alert.merchant!)
        : ('narration', alert.narration);
    if (matchValue == null) return rules;

    existing = rules
        .where((r) =>
            r.matchType == matchType &&
            r.matchValue.toLowerCase() == matchValue.toLowerCase())
        .firstOrNull;
    if (existing == null) {
      return [
        ...rules,
        CategorizationRule(
          id: newId(),
          matchType: matchType,
          matchValue: matchValue,
          category: category,
          type: type,
        ),
      ];
    }
  }

  final agrees = existing.category == category && existing.type == type;
  final confirmations = existing.confirmations + 1;
  final updated = agrees
      ? existing.copyWith(
          confirmations: confirmations,
          autoConfirm: existing.autoConfirm || confirmations == autoConfirmThreshold,
        )
      : existing.copyWith(
          category: category,
          type: type,
          confirmations: 1,
          autoConfirm: false,
        );

  return [for (final r in rules) r.id == updated.id ? updated : r];
}
