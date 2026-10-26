enum TransactionType {
  expense,
  income,
  fee,
  transfer,
  cash;

  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
      case TransactionType.fee:
        return 'Bank Fee';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.cash:
        return 'Cash';
    }
  }
}

enum TransactionSource {
  manual,
  bankAlert,
  reconciliation;

  String get displayName {
    switch (this) {
      case TransactionSource.manual:
        return 'Manual';
      case TransactionSource.bankAlert:
        return 'Bank Alert';
      case TransactionSource.reconciliation:
        return 'Reconciled';
    }
  }
}

enum TransactionStatus {
  confirmed,
  pending;

  bool get isPending => this == TransactionStatus.pending;
}

class TransactionItem {
  final String id;
  final double amount;
  final String currency;
  final TransactionType type;
  final String? category;
  final String? note;
  final DateTime date;
  final bool isIncome;
  final TransactionSource source;
  final TransactionStatus status;
  final String? accountId;
  final String? merchant;
  final String? narration;
  final String? location;
  final double? balanceAfter;
  final String? rawMessage;
  final String? messageHash;
  final String? linkedTransactionId;
  final String? ruleId;

  const TransactionItem({
    required this.id,
    required this.amount,
    this.currency = 'GHS',
    required this.type,
    this.category,
    this.note,
    required this.date,
    this.isIncome = false,
    this.source = TransactionSource.manual,
    this.status = TransactionStatus.confirmed,
    this.accountId,
    this.merchant,
    this.narration,
    this.location,
    this.balanceAfter,
    this.rawMessage,
    this.messageHash,
    this.linkedTransactionId,
    this.ruleId,
  });

  TransactionItem copyWith({
    String? id,
    double? amount,
    String? currency,
    TransactionType? type,
    String? category,
    String? note,
    DateTime? date,
    bool? isIncome,
    TransactionSource? source,
    TransactionStatus? status,
    String? accountId,
    String? merchant,
    String? narration,
    String? location,
    double? balanceAfter,
    String? rawMessage,
    String? messageHash,
    String? linkedTransactionId,
    String? ruleId,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      source: source ?? this.source,
      status: status ?? this.status,
      accountId: accountId ?? this.accountId,
      merchant: merchant ?? this.merchant,
      narration: narration ?? this.narration,
      location: location ?? this.location,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      rawMessage: rawMessage ?? this.rawMessage,
      messageHash: messageHash ?? this.messageHash,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
      ruleId: ruleId ?? this.ruleId,
    );
  }
}
