import '../../../core/models/account.dart';
import '../../../core/models/rule.dart';
import '../../../core/models/transaction.dart';
import '../data/parsers/parsed_alert.dart';
import 'alert_classifier.dart';
import 'rule_engine.dart';

/// What to save after processing one alert.
class AlertOutcome {
  final bool isDuplicate;

  /// New transactions; route each by its `status` (confirmed vs pending).
  final List<TransactionItem> transactions;

  /// The alert's account — newly created or with an updated balance.
  /// Null when nothing about the account changed.
  final Account? account;

  const AlertOutcome({
    this.isDuplicate = false,
    this.transactions = const [],
    this.account,
  });
}

/// Turns a parsed alert into transactions (doc.md §6 pipeline): resolves the
/// account, drops duplicates, classifies, applies learned rules, splits out
/// fees and reconciles against the reported balance.
class AlertProcessor {
  final String Function() newId;

  const AlertProcessor({required this.newId});

  AlertOutcome process(
    ParsedAlert alert, {
    required DateTime receivedAt,
    required List<Account> accounts,
    required List<TransactionItem> existing,
    required List<CategorizationRule> rules,
  }) {
    final date = _effectiveDate(alert.date, receivedAt);
    final hash = alertMessageHash(alert.rawMessage);
    final matchedAccount = _resolveAccount(alert, accounts);
    final account = matchedAccount ??
        Account(
          id: newId(),
          name: BankProvider.findById(alert.providerId).name,
          provider: alert.providerId,
          maskedNumber: alert.maskedAccount ?? '',
          lastBalance: alert.balanceAfter ?? 0,
          lastBalanceDate: date,
        );

    if (_isDuplicate(alert, hash, date, account.id, existing)) {
      return const AlertOutcome(isDuplicate: true);
    }

    final classification = classifyAlert(alert);
    final rule = classification.needsInput
        ? findMatchingRule(rules,
            narration: alert.narration, counterparty: alert.counterparty)
        : null;
    final type = rule?.type ?? classification.type;
    final confirmed = !classification.needsInput || (rule?.autoConfirm ?? false);

    final main = TransactionItem(
      id: newId(),
      amount: alert.amount,
      currency: alert.currency,
      type: type,
      category: rule?.category ?? classification.category,
      date: date,
      isIncome: type == TransactionType.income,
      source: TransactionSource.bankAlert,
      status: confirmed ? TransactionStatus.confirmed : TransactionStatus.pending,
      accountId: account.id,
      merchant: alert.counterparty,
      narration: alert.narration,
      location: alert.location,
      balanceAfter: alert.balanceAfter,
      rawMessage: alert.rawMessage,
      messageHash: hash,
      ruleId: rule?.id,
    );
    final transactions = [main];

    final fee = alert.fee ?? 0;
    if (fee > 0) {
      transactions.add(TransactionItem(
        id: newId(),
        amount: fee,
        currency: alert.currency,
        type: TransactionType.fee,
        category: 'Bank Fees',
        date: date,
        source: TransactionSource.bankAlert,
        accountId: account.id,
        merchant: BankProvider.findById(alert.providerId).name,
        narration: 'Fee: ${alert.narration ?? alert.counterparty ?? 'transaction'}',
        linkedTransactionId: main.id,
      ));
    }

    final balance = alert.balanceAfter;
    final isLatest = matchedAccount == null || !date.isBefore(account.lastBalanceDate);
    if (balance == null || !isLatest) {
      // Out-of-order alerts don't move the balance or trigger reconciliation.
      return AlertOutcome(
        transactions: transactions,
        account: matchedAccount == null ? account : null,
      );
    }

    if (matchedAccount != null) {
      final unaccounted = _reconcile(alert, fee, balance, account, date);
      if (unaccounted != null) transactions.add(unaccounted);
    }

    return AlertOutcome(
      transactions: transactions,
      account: account.copyWith(lastBalance: balance, lastBalanceDate: date),
    );
  }

  /// Creates a pending "Unaccounted" entry when the reported balance doesn't
  /// follow from the previous one (doc.md §9.2).
  TransactionItem? _reconcile(
    ParsedAlert alert,
    double fee,
    double balance,
    Account account,
    DateTime date,
  ) {
    final delta = (alert.isDebit ? -alert.amount : alert.amount) - fee;
    final gap = _round2(account.lastBalance + delta - balance);
    if (gap.abs() < 0.01) return null;

    final leftUnseen = gap > 0;
    return TransactionItem(
      id: newId(),
      amount: gap.abs(),
      currency: alert.currency,
      type: leftUnseen ? TransactionType.expense : TransactionType.income,
      date: date.subtract(const Duration(seconds: 1)),
      isIncome: !leftUnseen,
      source: TransactionSource.reconciliation,
      status: TransactionStatus.pending,
      accountId: account.id,
      narration: leftUnseen
          ? 'Unaccounted: left ${account.name} without an alert'
          : 'Unaccounted: arrived in ${account.name} without an alert',
    );
  }
}

/// Uses the arrival time when the alert gives only a date for the same day.
DateTime _effectiveDate(DateTime? stated, DateTime receivedAt) {
  if (stated == null) return receivedAt;
  final hasTime = stated.hour != 0 || stated.minute != 0;
  final sameDay = stated.year == receivedAt.year &&
      stated.month == receivedAt.month &&
      stated.day == receivedAt.day;
  return !hasTime && sameDay ? receivedAt : stated;
}

Account? _resolveAccount(ParsedAlert alert, List<Account> accounts) {
  final sameProvider = accounts.where((a) => a.provider == alert.providerId);
  final masked = alert.maskedAccount;
  if (masked == null) {
    // Wallet alerts carry no account number; use the provider's account.
    return sameProvider.where((a) => a.isDefault).firstOrNull ??
        sameProvider.firstOrNull;
  }
  return sameProvider
      .where((a) => _sameMaskedNumber(a.maskedNumber, masked))
      .firstOrNull;
}

/// Compares the visible trailing digits ("140*******721" vs "**721").
bool _sameMaskedNumber(String a, String b) {
  final tail = RegExp(r'(\d+)$');
  final x = tail.firstMatch(a)?.group(1);
  final y = tail.firstMatch(b)?.group(1);
  if (x == null || y == null || x.length < 3 || y.length < 3) return a == b;
  return x.endsWith(y) || y.endsWith(x);
}

/// Same account, amount, day and reported balance — or the exact same
/// message — is one alert seen twice (doc.md §9.1).
bool _isDuplicate(
  ParsedAlert alert,
  String hash,
  DateTime date,
  String accountId,
  List<TransactionItem> existing,
) {
  return existing.any((tx) {
    if (tx.messageHash == hash) return true;
    return alert.balanceAfter != null &&
        tx.accountId == accountId &&
        tx.amount == alert.amount &&
        tx.balanceAfter == alert.balanceAfter &&
        tx.date.year == date.year &&
        tx.date.month == date.month &&
        tx.date.day == date.day;
  });
}

/// Stable FNV-1a hash of the whitespace-normalised message.
String alertMessageHash(String message) {
  var hash = 0x811c9dc5;
  for (final unit in message.replaceAll(RegExp(r'\s+'), ' ').trim().codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

double _round2(double value) => (value * 100).roundToDouble() / 100;
