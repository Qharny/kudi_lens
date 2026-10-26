import 'transaction.dart';

class CategorizationRule {
  final String id;
  final String matchType; // 'narration', 'recipient', 'pattern'
  final String matchValue;
  final String category;
  final TransactionType type;
  final int confirmations;
  final bool autoConfirm;

  const CategorizationRule({
    required this.id,
    required this.matchType,
    required this.matchValue,
    required this.category,
    required this.type,
    this.confirmations = 1,
    this.autoConfirm = false,
  });

  CategorizationRule copyWith({
    String? id,
    String? matchType,
    String? matchValue,
    String? category,
    TransactionType? type,
    int? confirmations,
    bool? autoConfirm,
  }) {
    return CategorizationRule(
      id: id ?? this.id,
      matchType: matchType ?? this.matchType,
      matchValue: matchValue ?? this.matchValue,
      category: category ?? this.category,
      type: type ?? this.type,
      confirmations: confirmations ?? this.confirmations,
      autoConfirm: autoConfirm ?? this.autoConfirm,
    );
  }
}
