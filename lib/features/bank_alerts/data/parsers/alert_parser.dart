import 'ghana_parsers.dart';
import 'parsed_alert.dart';

const _currency = r'(?:GHS|GH₵|GH¢|GHC)\s?';
const _number = r'\d[\d,]*(?:\.\d+)?';

/// Placeholders usable in template sources, expanded into named groups.
const _tokens = {
  '{MONEY}': '$_currency(?<amount>$_number)',
  '{BAL}': '$_currency(?<balance>$_number)',
  '{FEE}': '$_currency(?<fee>$_number)',
  '{ACC}': r'(?<account>[\d*xX]+)',
  '{DATE}':
      r'(?<date>\d{1,2}[ \-/](?:[A-Za-z]{3}|\d{1,2})[ \-/]\d{4}(?: \d{1,2}:\d{2})?)',
};

/// One message format. Recognised named groups: `amount` (required), `dir`,
/// `account`, `date`, `narration`, `counterparty`, `location`, `balance`, `fee`.
class AlertTemplate {
  final RegExp pattern;

  /// Fixed direction; when null it is read from the `dir` group.
  final AlertDirection? direction;
  final String? defaultNarration;

  AlertTemplate(String source, {this.direction, this.defaultNarration})
      : pattern = RegExp(
          _tokens.entries
              .fold(source, (s, token) => s.replaceAll(token.key, token.value)),
          caseSensitive: false,
        );
}

class AlertParser {
  /// Matches [BankProvider.id].
  final String providerId;
  final List<String> senderIds;
  final List<AlertTemplate> templates;

  AlertParser({
    required this.providerId,
    required this.senderIds,
    required this.templates,
  });

  bool matchesSender(String sender) {
    final normalised = _normaliseSender(sender);
    return senderIds.any((id) => _normaliseSender(id) == normalised);
  }

  ParsedAlert? parse(String message) {
    final text = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    for (final template in templates) {
      final match = template.pattern.firstMatch(text);
      if (match == null) continue;

      String? group(String name) => match.groupNames.contains(name)
          ? _clean(match.namedGroup(name))
          : null;

      return ParsedAlert(
        providerId: providerId,
        direction: template.direction ?? _parseDirection(group('dir')!),
        amount: _parseAmount(group('amount'))!,
        maskedAccount: group('account'),
        date: _parseDate(group('date')),
        narration: group('narration') ?? template.defaultNarration,
        counterparty: group('counterparty'),
        location: group('location'),
        balanceAfter: _parseAmount(group('balance')),
        fee: _parseAmount(group('fee')),
        rawMessage: message,
      );
    }
    return null;
  }
}

class AlertParserRegistry {
  final List<AlertParser> parsers;

  AlertParserRegistry([List<AlertParser>? parsers])
      : parsers = parsers ?? ghanaAlertParsers;

  static final _nonTransactional = RegExp(
    r'\b(OTP|one[- ]time|verification code|passcode|PIN|promo|balance enquiry)\b',
    caseSensitive: false,
  );

  /// Parses [message] with the parsers registered for [sender]. Unknown or
  /// missing senders are tried against every parser. A known sender whose
  /// templates all fail is treated as a new format, not retried elsewhere.
  AlertParseResult parse(String message, {String? sender}) {
    final bySender = sender == null
        ? const <AlertParser>[]
        : parsers.where((p) => p.matchesSender(sender)).toList();

    for (final parser in bySender.isEmpty ? parsers : bySender) {
      final alert = parser.parse(message);
      if (alert != null) return AlertParsed(alert);
    }
    if (_nonTransactional.hasMatch(message)) return const AlertIgnored();
    return const AlertUnrecognised();
  }
}

String _normaliseSender(String sender) =>
    sender.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

/// Trims whitespace and trailing dots ("CalPay MTN Pull Txn.." → "… Txn").
String? _clean(String? value) {
  final cleaned = value?.replaceAll(RegExp(r'[\s.]+$'), '').trim();
  return cleaned == null || cleaned.isEmpty ? null : cleaned;
}

AlertDirection _parseDirection(String word) =>
    word.toLowerCase().startsWith('d') ? AlertDirection.debit : AlertDirection.credit;

double? _parseAmount(String? raw) =>
    raw == null ? null : double.tryParse(raw.replaceAll(',', ''));

const _months = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

/// Parses "26 OCT 2026", "26-OCT-2026" and "26/10/2026 14:22".
DateTime? _parseDate(String? raw) {
  if (raw == null) return null;
  final match = RegExp(
    r'^(\d{1,2})[ \-/]([A-Za-z]{3}|\d{1,2})[ \-/](\d{4})(?: (\d{1,2}):(\d{2}))?$',
  ).firstMatch(raw);
  if (match == null) return null;

  final monthText = match[2]!;
  final month = int.tryParse(monthText) ?? _months.indexOf(monthText.toUpperCase()) + 1;
  if (month < 1 || month > 12) return null;

  return DateTime(
    int.parse(match[3]!),
    month,
    int.parse(match[1]!),
    int.parse(match[4] ?? '0'),
    int.parse(match[5] ?? '0'),
  );
}
