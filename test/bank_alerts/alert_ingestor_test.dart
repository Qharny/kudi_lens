import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudi_lens/core/models/transaction.dart';
import 'package:kudi_lens/core/storage/record_store.dart';
import 'package:kudi_lens/features/accounts/data/account_provider.dart';
import 'package:kudi_lens/features/bank_alerts/data/alert_channel.dart';
import 'package:kudi_lens/features/bank_alerts/data/alert_ingestor.dart';
import 'package:kudi_lens/features/bank_alerts/data/pending_alerts_provider.dart';
import 'package:kudi_lens/features/bank_alerts/data/unrecognised_alerts_provider.dart';
import 'package:kudi_lens/features/transactions/data/transaction_provider.dart';

class FakeAlertChannel extends AlertChannel {
  final List<RawAlert> queue;
  final List<int> acknowledged = [];
  int pendingCountWhenAcknowledged = -1;
  final ProviderContainer Function() container;

  FakeAlertChannel(this.queue, this.container);

  @override
  Future<List<RawAlert>> pendingAlerts() async => [...queue];

  @override
  Future<void> acknowledge(int count) async {
    pendingCountWhenAcknowledged = container().read(pendingAlertsProvider).length;
    acknowledged.add(count);
    queue.removeRange(0, count);
  }
}

RawAlert raw(String sender, String message, [int minute = 0]) => RawAlert(
      sender: sender,
      message: message,
      receivedAt: DateTime(2026, 10, 26, 12, minute),
    );

const gcbPos =
    'Acc: 101*******402 debited with GHS 240.00 on 26 OCT 2026. Info: POS CHOP BAR OSU. Avail Bal: GHS 1,180.00.';
const gcbFee =
    'Acc: 101*******402 debited with GHS 2.00 on 26 OCT 2026. Info: SMS Alert Fee. Avail Bal: GHS 1,178.00.';
const unknownZenith = 'Zenith: Your acct was charged GHS 10.00 today. Bal GHS 90.00';

/// A container whose stores start empty (no debug sample data).
ProviderContainer emptyContainer({List<Override> overrides = const []}) {
  final storage = AppStorage.inMemory();
  for (final store in [
    storage.transactions,
    storage.pendingAlerts,
    storage.accounts,
    storage.rules,
    storage.unrecognisedAlerts,
  ]) {
    store.markInitialised();
  }
  return ProviderContainer(overrides: [
    appStorageProvider.overrideWithValue(storage),
    ...overrides,
  ]);
}

void main() {
  test('routes parsed, unrecognised and ignored alerts', () {
    final container = emptyContainer();
    addTearDown(container.dispose);

    container.read(alertIngestorProvider).ingest([
      raw('GCB', gcbFee, 5),
      raw('GCB', gcbPos, 1),
      raw('Zenith', unknownZenith, 2),
      raw('GCB', 'Your OTP is 123456', 3),
    ]);

    final pending = container.read(pendingAlertsProvider);
    expect(pending.single.narration, 'POS CHOP BAR OSU');

    final confirmed = container.read(transactionProvider);
    expect(confirmed.single.type, TransactionType.fee);

    final accounts = container.read(accountProvider);
    expect(accounts.single.provider, 'gcb');
    // Processed in arrival order, so the fee's balance is the latest.
    expect(accounts.single.lastBalance, 1178.00);

    final unrecognised = container.read(unrecognisedAlertsProvider);
    expect(unrecognised.single.sender, 'Zenith');
  });

  test('re-delivered alerts are not saved twice', () {
    final container = emptyContainer();
    addTearDown(container.dispose);
    final ingestor = container.read(alertIngestorProvider);

    ingestor.ingest([raw('GCB', gcbPos), raw('Zenith', unknownZenith)]);
    ingestor.ingest([raw('GCB', gcbPos), raw('Zenith', unknownZenith)]);

    expect(container.read(pendingAlertsProvider), hasLength(1));
    expect(container.read(unrecognisedAlertsProvider), hasLength(1));
  });

  test('drainQueue acknowledges alerts only after saving them', () async {
    late ProviderContainer container;
    final channel = FakeAlertChannel([raw('GCB', gcbPos)], () => container);
    container = emptyContainer(
      overrides: [alertChannelProvider.overrideWithValue(channel)],
    );
    addTearDown(container.dispose);

    await container.read(alertIngestorProvider).drainQueue();

    expect(channel.acknowledged, [1]);
    expect(channel.pendingCountWhenAcknowledged, 1);
    expect(channel.queue, isEmpty);
  });
}
