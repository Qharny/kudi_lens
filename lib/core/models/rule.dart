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

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchType': matchType,
        'matchValue': matchValue,
        'category': category,
        'type': type.name,
        'confirmations': confirmations,
        'autoConfirm': autoConfirm,
      };

  factory CategorizationRule.fromJson(Map<String, dynamic> json) {
    return CategorizationRule(
      id: json['id'] as String,
      matchType: json['matchType'] as String,
      matchValue: json['matchValue'] as String,
      category: json['category'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      confirmations: json['confirmations'] as int? ?? 1,
      autoConfirm: json['autoConfirm'] as bool? ?? false,
    );
  }
}
