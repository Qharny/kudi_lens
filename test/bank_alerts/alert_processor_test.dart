import 'package:flutter_test/flutter_test.dart';
import 'package:kudi_lens/core/models/account.dart';
import 'package:kudi_lens/core/models/rule.dart';
import 'package:kudi_lens/core/models/transaction.dart';
import 'package:kudi_lens/features/bank_alerts/data/parsers/alert_parser.dart';
import 'package:kudi_lens/features/bank_alerts/data/parsers/parsed_alert.dart';
import 'package:kudi_lens/features/bank_alerts/domain/alert_classifier.dart';
import 'package:kudi_lens/features/bank_alerts/domain/alert_processor.dart';
import 'package:kudi_lens/features/bank_alerts/domain/rule_engine.dart';

const calbankFee =
    'A/C No.: 140*******721 has been debited with GHS 2.00 on 21 OCT 2026 @BNK. Info: Transfer Charges. Avail. bal: GHS 268.42. Thank you.';
const calbankPull =
    'A/C No.: 140*******721 has been debited with GHS 30.00 on 21 OCT 2026 Tarkwa. Info: CalPay MTN Pull Txn.. Avail. bal: GHS 238.42. Thank you.';
const gcbPos =
    'Acc: 101*******402 debited with GHS 240.00 on 26 OCT 2026. Info: POS CHOP BAR OSU. Avail Bal: GHS 1,180.00.';
const gcbSalary =
    'Acc: 101*******402 credited with GHS 3,500.00 on 25 OCT 2026. Info: SALARY OCT. Avail Bal: GHS 4,680.00.';
const momoPayment =
    'Payment made for GHS 35.00 to 0551234567. Current Balance: GHS 415.00. Reference: Lunch. Fee was GHS 0.00.';
const momoCashOut =
    'Cash Out of GHS 100.00 received from Agent 249012. Fee: GHS 1.00. Balance: GHS 314.00.';

ParsedAlert parsed(String message) =>
    (AlertParserRegistry().parse(message) as AlertParsed).alert;

Account account(String provider, String masked, double balance, DateTime at) =>
    Account(
      id: 'acc_$provider',
      name: '$provider account',
      provider: provider,
      maskedNumber: masked,
      lastBalance: balance,
      lastBalanceDate: at,
    );

void main() {
  late int ids;
  late AlertProcessor processor;
  final oct21 = DateTime(2026, 10, 21, 9, 0);

  setUp(() {
    ids = 0;
    processor = AlertProcessor(newId: () => 'id${ids++}');
  });

  AlertOutcome process(
    String message, {
    List<Account> accounts = const [],
    List<TransactionItem> existing = const [],
    List<CategorizationRule> rules = const [],
    DateTime? receivedAt,
  }) =>
      processor.process(
        parsed(message),
        receivedAt: receivedAt ?? oct21,
        accounts: accounts,
        existing: existing,
        rules: rules,
      );

  group('classifyAlert (doc.md §8)', () {
    test('fees, transfers and cash need no input', () {
      final fee = classifyAlert(parsed(calbankFee));
      expect((fee.type, fee.category, fee.needsInput),
          (TransactionType.fee, 'Bank Fees', false));

      final pull = classifyAlert(parsed(calbankPull));
      expect((pull.type, pull.category, pull.needsInput),
          (TransactionType.transfer, 'Transfers', false));

      final cash = classifyAlert(parsed(momoCashOut));
      expect((cash.type, cash.needsInput), (TransactionType.cash, false));
    });

    test('purchases and unknown credits ask the user', () {
      final pos = classifyAlert(parsed(gcbPos));
      expect((pos.type, pos.needsInput), (TransactionType.expense, true));

      final salary = classifyAlert(parsed(gcbSalary));
      expect((salary.type, salary.needsInput), (TransactionType.income, true));
    });
  });

  group('AlertProcessor', () {
    test('matches the account by masked number and updates its balance', () {
      final calbank = account('calbank', '140***721', 270.42, oct21.subtract(const Duration(days: 1)));
      final out = process(calbankFee, accounts: [calbank]);

      expect(out.transactions, hasLength(1));
      final tx = out.transactions.single;
      expect(tx.type, TransactionType.fee);
      expect(tx.status, TransactionStatus.confirmed);
      expect(tx.accountId, calbank.id);
      expect(tx.messageHash, isNotNull);
      expect(out.account!.id, calbank.id);
      expect(out.account!.lastBalance, 268.42);
    });

    test('balance gap creates a pending Unaccounted entry (doc.md §9.2)', () {
      final calbank = account('calbank', '140***721', 300.00, oct21.subtract(const Duration(days: 1)));
      final out = process(calbankFee, accounts: [calbank]);

      expect(out.transactions, hasLength(2));
      final gap = out.transactions.last;
      expect(gap.amount, 29.58);
      expect(gap.type, TransactionType.expense);
      expect(gap.source, TransactionSource.reconciliation);
      expect(gap.status, TransactionStatus.pending);
      expect(gap.date.isBefore(out.transactions.first.date), isTrue);
    });

    test('unexpected extra money is flagged as unaccounted income', () {
      final calbank = account('calbank', '140***721', 250.00, oct21.subtract(const Duration(days: 1)));
      final gap = process(calbankFee, accounts: [calbank]).transactions.last;
      expect(gap.type, TransactionType.income);
      expect(gap.amount, 20.42);
    });

    test('same alert seen twice is a duplicate', () {
      final first = process(gcbPos);
      final second = process(gcbPos, accounts: [first.account!], existing: first.transactions);
      expect(second.isDuplicate, isTrue);
      expect(second.transactions, isEmpty);
    });

    test('identical charges with different balances are both kept (doc.md §9.1)', () {
      final first = process(calbankFee);
      final again = calbankFee.replaceFirst('268.42', '266.42');
      final second = process(again, accounts: [first.account!], existing: first.transactions);
      expect(second.isDuplicate, isFalse);
      expect(second.transactions.first.amount, 2.00);
    });

    test('unknown account is created from the alert', () {
      final out = process(gcbPos, receivedAt: DateTime(2026, 10, 26, 13, 5));
      expect(out.account!.provider, 'gcb');
      expect(out.account!.maskedNumber, '101*******402');
      expect(out.account!.lastBalance, 1180.00);
      expect(out.transactions.single.status, TransactionStatus.pending);
      // Same-day date without a time uses the arrival time.
      expect(out.transactions.single.date, DateTime(2026, 10, 26, 13, 5));
    });

    test('learned rules pre-fill pending alerts and auto-confirm when trusted', () {
      const rule = CategorizationRule(
        id: 'r1',
        matchType: 'narration',
        matchValue: 'chop bar',
        category: 'Food & Dining',
        type: TransactionType.expense,
      );

      final asking = process(gcbPos, rules: [rule]).transactions.single;
      expect(asking.category, 'Food & Dining');
      expect(asking.ruleId, 'r1');
      expect(asking.status, TransactionStatus.pending);

      final trusted =
          process(gcbPos, rules: [rule.copyWith(autoConfirm: true)]).transactions.single;
      expect(trusted.status, TransactionStatus.confirmed);
    });

    test('learned rules do not override built-in fee classification', () {
      const rule = CategorizationRule(
        id: 'r1',
        matchType: 'narration',
        matchValue: 'Transfer',
        category: 'Shopping',
        type: TransactionType.expense,
        autoConfirm: true,
      );
      final tx = process(calbankFee, rules: [rule]).transactions.single;
      expect(tx.type, TransactionType.fee);
      expect(tx.ruleId, isNull);
    });

    test('MoMo fee is split into a linked fee transaction and reconciled', () {
      final momo = account('mtn_momo', '024***89', 415.00, oct21.subtract(const Duration(hours: 1)));
      final out = process(momoCashOut, accounts: [momo]);

      expect(out.transactions, hasLength(2));
      final [main, fee] = out.transactions;
      expect(main.type, TransactionType.cash);
      expect(main.accountId, momo.id);
      expect(fee.type, TransactionType.fee);
      expect(fee.amount, 1.00);
      expect(fee.linkedTransactionId, main.id);
      expect(out.account!.lastBalance, 314.00);
    });

    test('zero fees are not recorded', () {
      expect(process(momoPayment).transactions, hasLength(1));
    });

    test('out-of-order alert neither moves the balance nor reconciles', () {
      final calbank = account('calbank', '140***721', 999.00, DateTime(2026, 10, 22));
      final out = process(calbankFee, accounts: [calbank]);
      expect(out.transactions, hasLength(1));
      expect(out.account, isNull);
    });
  });

  group('learnFromConfirmation (doc.md §11)', () {
    final bankAlert = TransactionItem(
      id: 't',
      amount: 240,
      type: TransactionType.expense,
      date: oct21,
      narration: 'POS CHOP BAR OSU',
    );
    final momoAlert = TransactionItem(
      id: 'm',
      amount: 35,
      type: TransactionType.expense,
      date: oct21,
      merchant: '0551234567',
      narration: 'Lunch',
    );

    List<CategorizationRule> learn(List<CategorizationRule> rules, TransactionItem tx,
            [String category = 'Food & Dining']) =>
        learnFromConfirmation(rules, tx,
            category: category, type: TransactionType.expense, newId: () => 'new');

    test('creates a narration rule for bank alerts and a recipient rule for MoMo', () {
      final bankRule = learn([], bankAlert).single;
      expect((bankRule.matchType, bankRule.matchValue), ('narration', 'POS CHOP BAR OSU'));

      final momoRule = learn([], momoAlert).single;
      expect((momoRule.matchType, momoRule.matchValue), ('recipient', '0551234567'));
    });

    test('auto-confirms after three consistent answers', () {
      var rules = learn([], bankAlert);
      expect(rules.single.autoConfirm, isFalse);
      rules = learn(rules, bankAlert);
      expect(rules.single.autoConfirm, isFalse);
      rules = learn(rules, bankAlert);
      expect(rules.single.confirmations, autoConfirmThreshold);
      expect(rules.single.autoConfirm, isTrue);
    });

    test('a different answer resets the rule to ask again', () {
      var rules = learn(learn(learn([], bankAlert), bankAlert), bankAlert);
      rules = learn(rules, bankAlert, 'Entertainment');
      expect(rules.single.category, 'Entertainment');
      expect(rules.single.confirmations, 1);
      expect(rules.single.autoConfirm, isFalse);
    });

    test('confirming a rule-filled alert strengthens that rule', () {
      const applied = CategorizationRule(
        id: 'r1',
        matchType: 'narration',
        matchValue: 'CHOP BAR',
        category: 'Food & Dining',
        type: TransactionType.expense,
        confirmations: 2,
      );
      final rules = learn([applied], bankAlert.copyWith(ruleId: 'r1'));
      expect(rules.single.id, 'r1');
      expect(rules.single.confirmations, 3);
      expect(rules.single.autoConfirm, isTrue);
    });
  });
}
