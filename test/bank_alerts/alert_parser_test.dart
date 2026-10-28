import 'package:flutter_test/flutter_test.dart';
import 'package:kudi_lens/features/bank_alerts/data/parsers/alert_parser.dart';
import 'package:kudi_lens/features/bank_alerts/data/parsers/parsed_alert.dart';

final registry = AlertParserRegistry();

ParsedAlert parse(String message, {String? sender}) {
  final result = registry.parse(message, sender: sender);
  expect(result, isA<AlertParsed>(), reason: message);
  return (result as AlertParsed).alert;
}

void main() {
  group('bank templates (doc.md §7 samples)', () {
    test('GCB debit', () {
      final a = parse(
        'Acc: 101*******402 debited with GHS 240.00 on 26 OCT 2026. Info: POS CHOP BAR OSU. Avail Bal: GHS 1,180.00.',
        sender: 'GCB',
      );
      expect(a.providerId, 'gcb');
      expect(a.direction, AlertDirection.debit);
      expect(a.amount, 240.00);
      expect(a.maskedAccount, '101*******402');
      expect(a.date, DateTime(2026, 10, 26));
      expect(a.narration, 'POS CHOP BAR OSU');
      expect(a.balanceAfter, 1180.00);
    });

    test('Ecobank Dr', () {
      final a = parse(
        'ECOBANK: Dr GHS 95.00 from A/c 144*******319 at TOTAL AIRPORT on 26-OCT-2026. Avail Bal GHS 755.50.',
        sender: 'Ecobank',
      );
      expect(a.providerId, 'ecobank');
      expect(a.direction, AlertDirection.debit);
      expect(a.amount, 95.00);
      expect(a.maskedAccount, '144*******319');
      expect(a.date, DateTime(2026, 10, 26));
      expect(a.narration, 'TOTAL AIRPORT');
      expect(a.balanceAfter, 755.50);
    });

    test('CalBank fee with @BNK channel', () {
      final a = parse(
        'A/C No.: 140*******721 has been debited with GHS 2.00 on 21 OCT 2026 @BNK. Info: Transfer Charges. Avail. bal: GHS 268.42. Thank you.',
        sender: 'CalBank',
      );
      expect(a.providerId, 'calbank');
      expect(a.amount, 2.00);
      expect(a.maskedAccount, '140*******721');
      expect(a.date, DateTime(2026, 10, 21));
      expect(a.location, '@BNK');
      expect(a.narration, 'Transfer Charges');
      expect(a.balanceAfter, 268.42);
    });

    test('CalBank multi-line alert with town and double-dot narration (doc.md §2)', () {
      final a = parse(
        'A/C No.: 140*******721 has been debited with GHS 30.00 on 21 JUL 2026 Tarkwa.\n'
        'Info: CalPay MTN Pull Txn.. Avail. bal: GHS 10.43. Thank you.',
        sender: 'CalBank',
      );
      expect(a.amount, 30.00);
      expect(a.date, DateTime(2026, 7, 21));
      expect(a.location, 'Tarkwa');
      expect(a.narration, 'CalPay MTN Pull Txn');
      expect(a.balanceAfter, 10.43);
    });

    test('Stanbic with numeric date and time', () {
      final a = parse(
        'Stanbic: Debit txn of GHS 150.00 on A/C **5012 on 26/10/2026 14:22. Desc: ACCRA MALL POS. Bal: GHS 3,410.00.',
        sender: 'Stanbic',
      );
      expect(a.providerId, 'stanbic');
      expect(a.direction, AlertDirection.debit);
      expect(a.amount, 150.00);
      expect(a.maskedAccount, '**5012');
      expect(a.date, DateTime(2026, 10, 26, 14, 22));
      expect(a.narration, 'ACCRA MALL POS');
      expect(a.balanceAfter, 3410.00);
    });

    test('Absa', () {
      final a = parse(
        'Absa: A debit of GHS 80.00 occurred on your account ending with 8812 on 26-OCT-2026. Ref: Kfc Junction. Available balance: GHS 1,940.00.',
        sender: 'Absa',
      );
      expect(a.providerId, 'absa');
      expect(a.amount, 80.00);
      expect(a.maskedAccount, '8812');
      expect(a.date, DateTime(2026, 10, 26));
      expect(a.narration, 'Kfc Junction');
      expect(a.balanceAfter, 1940.00);
    });

    test('Fidelity', () {
      final a = parse(
        'Fidelity Alert: Acct 209****101 has been debited for GHS 65.00 on 26-OCT-2026. Narration: PHARMACY EAST LEGON. Available Bal: GHS 520.00.',
        sender: 'Fidelity',
      );
      expect(a.providerId, 'fidelity');
      expect(a.amount, 65.00);
      expect(a.maskedAccount, '209****101');
      expect(a.narration, 'PHARMACY EAST LEGON');
      expect(a.balanceAfter, 520.00);
    });

    test('credit alerts use the same templates', () {
      final a = parse(
        'Acc: 101*******402 credited with GHS 3,500.00 on 25 OCT 2026. Info: SALARY OCT. Avail Bal: GHS 4,680.00.',
        sender: 'GCB',
      );
      expect(a.direction, AlertDirection.credit);
      expect(a.amount, 3500.00);

      final eco = parse(
        'ECOBANK: Cr GHS 200.00 to A/c 144*******319 on 26-OCT-2026. Avail Bal GHS 955.50.',
        sender: 'Ecobank',
      );
      expect(eco.direction, AlertDirection.credit);
      expect(eco.narration, isNull);
    });
  });

  group('wallet templates (doc.md §7 samples)', () {
    test('MTN MoMo payment with reference and fee', () {
      final a = parse(
        'Payment made for GHS 35.00 to 0551234567. Current Balance: GHS 415.00. Reference: Lunch. Fee was GHS 0.00.',
        sender: 'MobileMoney',
      );
      expect(a.providerId, 'mtn_momo');
      expect(a.direction, AlertDirection.debit);
      expect(a.amount, 35.00);
      expect(a.counterparty, '0551234567');
      expect(a.balanceAfter, 415.00);
      expect(a.narration, 'Lunch');
      expect(a.fee, 0.00);
      expect(a.date, isNull);
    });

    test('MTN MoMo cash out', () {
      final a = parse(
        'Cash Out of GHS 100.00 received from Agent 249012. Fee: GHS 1.00. Balance: GHS 314.00.',
        sender: 'MTN MoMo',
      );
      expect(a.direction, AlertDirection.debit);
      expect(a.amount, 100.00);
      expect(a.counterparty, 'Agent 249012');
      expect(a.narration, 'Cash Out');
      expect(a.fee, 1.00);
      expect(a.balanceAfter, 314.00);
    });

    test('Telecel Cash payment', () {
      final a = parse(
        'You have paid GHS 50.00 to Telecel Merchant 338102. Fee: GHS 0.00. Balance: GHS 280.00.',
        sender: 'Telecel',
      );
      expect(a.providerId, 'telecel');
      expect(a.amount, 50.00);
      expect(a.counterparty, 'Telecel Merchant 338102');
      expect(a.balanceAfter, 280.00);
    });

    test('AT Money transfer', () {
      final a = parse(
        'Transfer of GHS 40.00 to 0261234567 successful. New balance: GHS 190.00.',
        sender: 'AT Money',
      );
      expect(a.providerId, 'at_money');
      expect(a.amount, 40.00);
      expect(a.counterparty, '0261234567');
      expect(a.balanceAfter, 190.00);
    });
  });

  group('registry routing', () {
    const gcbAlert =
        'Acc: 101*******402 debited with GHS 240.00 on 26 OCT 2026. Info: POS CHOP BAR OSU. Avail Bal: GHS 1,180.00.';

    test('sender ids match regardless of case and spacing', () {
      expect(parse(gcbAlert, sender: 'gcb bank').providerId, 'gcb');
    });

    test('unknown or missing sender falls back to every parser', () {
      expect(parse(gcbAlert, sender: 'com.some.sms.app').providerId, 'gcb');
      expect(parse(gcbAlert).providerId, 'gcb');
    });

    test('known sender with an unmatched format is unrecognised, not misparsed', () {
      expect(registry.parse(gcbAlert, sender: 'Ecobank'), isA<AlertUnrecognised>());
    });

    test('OTPs and promos are ignored', () {
      expect(
        registry.parse('Your OTP is 482913. Do not share it.', sender: 'GCB'),
        isA<AlertIgnored>(),
      );
      expect(
        registry.parse('Enjoy our new promo on loans!', sender: 'Absa'),
        isA<AlertIgnored>(),
      );
    });

    test('unknown financial-looking text is unrecognised', () {
      expect(
        registry.parse('Your account was charged GHS 10 today.', sender: 'Zenith'),
        isA<AlertUnrecognised>(),
      );
    });
  });
}
