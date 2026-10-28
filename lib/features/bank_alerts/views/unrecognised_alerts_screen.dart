import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../data/unrecognised_alerts_provider.dart';

class UnrecognisedAlertsScreen extends ConsumerWidget {
  const UnrecognisedAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    final alerts = ref.watch(unrecognisedAlertsProvider);

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(title: const Text('Unrecognised Alerts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: palette.textPrimary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Financial messages that didn\'t match current bank templates are preserved here so new bank parsers can be built.',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (alerts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(
                child: Text(
                  'No unrecognised alerts',
                  style: TextStyle(color: palette.textMuted),
                ),
              ),
            ),
          ...alerts.map((item) {
            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) =>
                  ref.read(unrecognisedAlertsProvider.notifier).delete(item.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.sender,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          DateFormatter.formatShortDate(item.receivedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: palette.border),
                      ),
                      child: Text(
                        item.rawMessage,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: palette.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
