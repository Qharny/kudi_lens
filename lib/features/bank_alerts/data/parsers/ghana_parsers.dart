import 'alert_parser.dart';
import 'parsed_alert.dart';

/// Templates for the Ghanaian banks and wallets documented in doc.md §7.
/// Every template must be covered by a sample in alert_parser_test.dart.
final List<AlertParser> ghanaAlertParsers = [
  AlertParser(
    providerId: 'gcb',
    senderIds: ['GCB', 'GCBBank'],
    templates: [
      AlertTemplate(
        r'Acc:? {ACC} (?<dir>debited|credited) with {MONEY} on {DATE}\.? '
        r'Info: (?<narration>.+?)\.? Avail\.? Bal:? {BAL}',
      ),
    ],
  ),
  AlertParser(
    providerId: 'ecobank',
    senderIds: ['Ecobank', 'EcobankGH'],
    templates: [
      AlertTemplate(
        r'(?<dir>Dr|Cr) {MONEY} (?:from|to) A/c {ACC}(?: at (?<narration>.+?))? '
        r'on {DATE}\.? Avail\.? Bal:? {BAL}',
      ),
    ],
  ),
  AlertParser(
    providerId: 'calbank',
    senderIds: ['CalBank'],
    templates: [
      AlertTemplate(
        r'A/C No\.?:? {ACC} has been (?<dir>debited|credited) with {MONEY} '
        r'on {DATE}(?: (?<location>[^.]+?))?\.? Info: (?<narration>.+?)\.? '
        r'Avail\.? bal:? {BAL}',
      ),
    ],
  ),
  AlertParser(
    providerId: 'stanbic',
    senderIds: ['Stanbic', 'StanbicGH'],
    templates: [
      AlertTemplate(
        r'(?<dir>Debit|Credit) txn of {MONEY} on A/C {ACC} on {DATE}\.? '
        r'Desc: (?<narration>.+?)\.? Bal:? {BAL}',
      ),
    ],
  ),
  AlertParser(
    providerId: 'absa',
    senderIds: ['Absa', 'AbsaGhana'],
    templates: [
      AlertTemplate(
        r'A (?<dir>debit|credit) of {MONEY} occurred on your account ending '
        r'with {ACC} on {DATE}\.? Ref: (?<narration>.+?)\.? Available balance:? {BAL}',
      ),
    ],
  ),
  AlertParser(
    providerId: 'fidelity',
    senderIds: ['Fidelity', 'FidelityBk'],
    templates: [
      AlertTemplate(
        r'Acct {ACC} has been (?<dir>debited|credited) for {MONEY} on {DATE}\.? '
        r'Narration: (?<narration>.+?)\.? Available Bal:? {BAL}',
      ),
    ],
  ),
  AlertParser(
    providerId: 'mtn_momo',
    senderIds: ['MobileMoney', 'MTN MoMo'],
    templates: [
      AlertTemplate(
        r'Payment made for {MONEY} to (?<counterparty>[^.]+?)\.? '
        r'Current Balance:? {BAL}(?:\.? Reference: (?<narration>[^.]*))?'
        r'(?:\.? Fee (?:was|charged):? {FEE})?',
        direction: AlertDirection.debit,
      ),
      AlertTemplate(
        r'Cash Out of {MONEY} received from (?<counterparty>[^.]+?)\.? '
        r'Fee:? {FEE}\.? Balance:? {BAL}',
        direction: AlertDirection.debit,
        defaultNarration: 'Cash Out',
      ),
    ],
  ),
  AlertParser(
    providerId: 'telecel',
    senderIds: ['Telecel', 'TelecelCash'],
    templates: [
      AlertTemplate(
        r'You have paid {MONEY} to (?<counterparty>[^.]+?)\.? Fee:? {FEE}\.? '
        r'Balance:? {BAL}',
        direction: AlertDirection.debit,
      ),
    ],
  ),
  AlertParser(
    providerId: 'at_money',
    senderIds: ['AT Money', 'ATMoney', 'AirtelTigo'],
    templates: [
      AlertTemplate(
        r'Transfer of {MONEY} to (?<counterparty>\S+) successful\.? '
        r'New balance:? {BAL}',
        direction: AlertDirection.debit,
      ),
    ],
  ),
];
