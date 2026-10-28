import '../../../core/models/transaction.dart';
import '../data/parsers/parsed_alert.dart';

class AlertClassification {
  final TransactionType type;
  final String? category;

  /// Whether the user must add context before the transaction is confirmed.
  final bool needsInput;

  const AlertClassification(this.type, this.category, {required this.needsInput});
}

final _fee = RegExp(r'\b(charges?|fees?|levy|levies|commission)\b', caseSensitive: false);
final _transfer = RegExp(r'\b(MTN Pull|MoMo|mobile money|wallet)\b', caseSensitive: false);
final _cash = RegExp(r'\b(ATM|cash withdrawal|cash out)\b', caseSensitive: false);

/// Built-in narration rules from doc.md §8. Learned rules are applied on top
/// of this only when [AlertClassification.needsInput] is true.
AlertClassification classifyAlert(ParsedAlert alert) {
  final narration = alert.narration ?? '';

  if (!alert.isDebit) {
    return _transfer.hasMatch(narration)
        ? const AlertClassification(TransactionType.transfer, 'Transfers', needsInput: false)
        : const AlertClassification(TransactionType.income, null, needsInput: true);
  }
  if (_fee.hasMatch(narration)) {
    return const AlertClassification(TransactionType.fee, 'Bank Fees', needsInput: false);
  }
  if (_transfer.hasMatch(narration)) {
    return const AlertClassification(TransactionType.transfer, 'Transfers', needsInput: false);
  }
  if (_cash.hasMatch(narration)) {
    return const AlertClassification(TransactionType.cash, null, needsInput: false);
  }
  return const AlertClassification(TransactionType.expense, null, needsInput: true);
}
