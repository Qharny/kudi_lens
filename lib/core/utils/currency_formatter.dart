import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##0.00', 'en_US');

  static String format(double amount, {String currency = 'GHS'}) {
    return '$currency ${_formatter.format(amount)}';
  }

  static String formatCompact(double amount, {String currency = 'GHS'}) {
    if (amount >= 1000000) {
      return '$currency ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$currency ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return format(amount, currency: currency);
  }
}
