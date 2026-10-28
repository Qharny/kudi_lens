import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An alert as captured by the native notification listener.
class RawAlert {
  final String sender;
  final String message;
  final DateTime receivedAt;

  const RawAlert({
    required this.sender,
    required this.message,
    required this.receivedAt,
  });
}

/// Bridge to the Android `AlertListenerService` queue (MainActivity.kt).
/// On other platforms there is no listener: the queue is always empty.
class AlertChannel {
  static const _channel = MethodChannel('kudi_lens/alerts');

  const AlertChannel();

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Queued alerts, oldest first. They stay queued until [acknowledge].
  Future<List<RawAlert>> pendingAlerts() async {
    if (!isSupported) return const [];
    final raw = await _channel.invokeListMethod<Map<Object?, Object?>>('pendingAlerts');
    return [
      for (final alert in raw ?? const <Map<Object?, Object?>>[])
        RawAlert(
          sender: alert['sender'] as String,
          message: alert['message'] as String,
          receivedAt: DateTime.fromMillisecondsSinceEpoch(alert['receivedAt'] as int),
        ),
    ];
  }

  /// Removes the oldest [count] alerts once they have been saved.
  Future<void> acknowledge(int count) async {
    if (!isSupported || count == 0) return;
    await _channel.invokeMethod<void>('acknowledge', count);
  }

  Future<bool> isListenerEnabled() async {
    if (!isSupported) return false;
    return await _channel.invokeMethod<bool>('isListenerEnabled') ?? false;
  }

  Future<void> openListenerSettings() async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('openListenerSettings');
  }
}

final alertChannelProvider = Provider<AlertChannel>((ref) => const AlertChannel());
