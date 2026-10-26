class Account {
  final String id;
  final String name;
  final String provider; // 'calbank', 'mtn_momo', 'telecel', 'cash'
  final String maskedNumber;
  final double lastBalance;
  final DateTime lastBalanceDate;
  final bool isDefault;

  const Account({
    required this.id,
    required this.name,
    required this.provider,
    required this.maskedNumber,
    required this.lastBalance,
    required this.lastBalanceDate,
    this.isDefault = false,
  });

  Account copyWith({
    String? id,
    String? name,
    String? provider,
    String? maskedNumber,
    double? lastBalance,
    DateTime? lastBalanceDate,
    bool? isDefault,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      lastBalance: lastBalance ?? this.lastBalance,
      lastBalanceDate: lastBalanceDate ?? this.lastBalanceDate,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
