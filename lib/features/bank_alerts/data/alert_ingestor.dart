import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/unrecognised_alert.dart';
import '../../accounts/data/account_provider.dart';
import '../../rules/data/rules_provider.dart';
import '../../transactions/data/transaction_provider.dart';
import '../domain/alert_processor.dart';
import 'alert_channel.dart';
import 'parsers/alert_parser.dart';
import 'parsers/parsed_alert.dart';
import 'pending_alerts_provider.dart';
import 'unrecognised_alerts_provider.dart';

const _uuid = Uuid();

/// Drains the native alert queue and saves the results (doc.md §6).
class AlertIngestor {
  final Ref _ref;
  final AlertParserRegistry _registry = AlertParserRegistry();
  final AlertProcessor _processor = AlertProcessor(newId: _uuid.v4);
  bool _draining = false;

  AlertIngestor(this._ref);

  /// Called on app start and resume. Alerts are acknowledged (removed from
  /// the native queue) only after they have been saved.
  Future<void> drainQueue() async {
    if (_draining) return;
    _draining = true;
    try {
      final channel = _ref.read(alertChannelProvider);
      final alerts = await channel.pendingAlerts();
      if (alerts.isEmpty) return;
      ingest(alerts);
      await channel.acknowledge(alerts.length);
    } on MissingPluginException {
      // No native listener on this platform or in tests.
    } on PlatformException catch (e) {
      debugPrint('Failed to drain alert queue: $e');
    } finally {
      _draining = false;
    }
  }

  /// Parses and processes [alerts] in arrival order, routing each result to
  /// transactions, the pending inbox or unrecognised alerts.
  void ingest(List<RawAlert> alerts) {
    final ordered = [...alerts]..sort((a, b) => a.receivedAt.compareTo(b.receivedAt));
    for (final raw in ordered) {
      switch (_registry.parse(raw.message, sender: raw.sender)) {
        case AlertParsed(:final alert):
          _save(alert, raw.receivedAt);
        case AlertUnrecognised():
          _ref.read(unrecognisedAlertsProvider.notifier).add(UnrecognisedAlert(
                id: _uuid.v4(),
                sender: raw.sender,
                rawMessage: raw.message,
                receivedAt: raw.receivedAt,
              ));
        case AlertIgnored():
          break;
      }
    }
  }

  void _save(ParsedAlert alert, DateTime receivedAt) {
    final outcome = _processor.process(
      alert,
      receivedAt: receivedAt,
      accounts: _ref.read(accountProvider),
      existing: [..._ref.read(transactionProvider), ..._ref.read(pendingAlertsProvider)],
      rules: _ref.read(rulesProvider),
    );

    if (outcome.account case final account?) {
      _ref.read(accountProvider.notifier).upsertAccount(account);
    }
    for (final tx in outcome.transactions) {
      if (tx.status.isPending) {
        _ref.read(pendingAlertsProvider.notifier).addAlert(tx);
      } else {
        _ref.read(transactionProvider.notifier).addTransaction(tx);
      }
    }
  }
}

final alertIngestorProvider = Provider<AlertIngestor>((ref) => AlertIngestor(ref));
