enum AlertDirection { debit, credit }

/// Structured fields extracted from a single bank or MoMo alert.
class ParsedAlert {
  final String providerId;
  final AlertDirection direction;
  final double amount;
  final String currency;
  final String? maskedAccount;

  /// Date stated in the alert. Null when the alert carries none (most MoMo
  /// messages), in which case the arrival time should be used.
  final DateTime? date;
  final String? narration;

  /// Recipient or sender named in the alert (MoMo number, agent, merchant).
  final String? counterparty;
  final String? location;
  final double? balanceAfter;
  final double? fee;
  final String rawMessage;

  const ParsedAlert({
    required this.providerId,
    required this.direction,
    required this.amount,
    this.currency = 'GHS',
    this.maskedAccount,
    this.date,
    this.narration,
    this.counterparty,
    this.location,
    this.balanceAfter,
    this.fee,
    required this.rawMessage,
  });

  bool get isDebit => direction == AlertDirection.debit;
}

sealed class AlertParseResult {
  const AlertParseResult();
}

/// A template matched and the alert was parsed.
class AlertParsed extends AlertParseResult {
  final ParsedAlert alert;
  const AlertParsed(this.alert);
}

/// Not a transaction alert (OTP, promo, balance enquiry) — safe to drop.
class AlertIgnored extends AlertParseResult {
  const AlertIgnored();
}

/// Looks financial but no template matched — goes to "Unrecognised alerts".
class AlertUnrecognised extends AlertParseResult {
  const AlertUnrecognised();
}
