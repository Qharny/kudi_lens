class Account {
  final String id;
  final String name;
  final String provider; // 'gcb', 'ecobank', 'stanbic', 'absa', 'fidelity', 'calbank', 'zenith', 'access', 'stanchart', 'mtn_momo', 'telecel', 'at_money', 'cash'
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

  String get providerDisplayName => BankProvider.findById(provider).name;
  String get providerShortName => BankProvider.findById(provider).shortName;

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'provider': provider,
        'maskedNumber': maskedNumber,
        'lastBalance': lastBalance,
        'lastBalanceDate': lastBalanceDate.toIso8601String(),
        'isDefault': isDefault,
      };

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      maskedNumber: json['maskedNumber'] as String,
      lastBalance: (json['lastBalance'] as num).toDouble(),
      lastBalanceDate: DateTime.parse(json['lastBalanceDate'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class BankProvider {
  final String id;
  final String name;
  final String shortName;
  final bool isBank;
  final bool isWallet;

  const BankProvider({
    required this.id,
    required this.name,
    required this.shortName,
    this.isBank = false,
    this.isWallet = false,
  });

  static const List<BankProvider> all = [
    // Ghanaian Commercial Banks
    BankProvider(id: 'gcb', name: 'GCB Bank', shortName: 'GCB', isBank: true),
    BankProvider(id: 'ecobank', name: 'Ecobank Ghana', shortName: 'Ecobank', isBank: true),
    BankProvider(id: 'stanbic', name: 'Stanbic Bank', shortName: 'Stanbic', isBank: true),
    BankProvider(id: 'absa', name: 'Absa Bank Ghana', shortName: 'Absa', isBank: true),
    BankProvider(id: 'fidelity', name: 'Fidelity Bank', shortName: 'Fidelity', isBank: true),
    BankProvider(id: 'calbank', name: 'CalBank Ghana', shortName: 'CalBank', isBank: true),
    BankProvider(id: 'zenith', name: 'Zenith Bank', shortName: 'Zenith', isBank: true),
    BankProvider(id: 'access', name: 'Access Bank', shortName: 'Access', isBank: true),
    BankProvider(id: 'stanchart', name: 'Standard Chartered', shortName: 'Stanchart', isBank: true),
    // Mobile Money Wallets
    BankProvider(id: 'mtn_momo', name: 'MTN Mobile Money', shortName: 'MoMo', isWallet: true),
    BankProvider(id: 'telecel', name: 'Telecel Cash', shortName: 'Telecel', isWallet: true),
    BankProvider(id: 'at_money', name: 'AT Money (AirtelTigo)', shortName: 'AT Money', isWallet: true),
    // Cash
    BankProvider(id: 'cash', name: 'Cash Wallet', shortName: 'Cash', isWallet: true),
  ];

  static BankProvider findById(String id) {
    return all.firstWhere(
      (p) => p.id == id,
      orElse: () => BankProvider(id: id, name: id.toUpperCase(), shortName: id.toUpperCase()),
    );
  }
}

