import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';

class UnrecognisedAlertsScreen extends StatelessWidget {
  const UnrecognisedAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final samples = [
      {
        'sender': 'FidelityBank',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'raw':
            'Debit: GHS 120.00 on A/C **8912. Trans: ATM WDL TARKWA. Avail Bal: GHS 540.20. Date: 24/10/2026.',
      },
      {
        'sender': 'GCB Alert',
        'date': DateTime.now().subtract(const Duration(days: 4)),
        'raw':
            'Dear Customer, your Acct 204***112 was debited with GHS 50.00 for E-Levy charges. Bal: GHS 312.10.',
      },
    ];

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        title: const Text('Unrecognised Alerts'),
      ),
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
                Icon(Icons.lightbulb_outline_rounded,
                    color: palette.textPrimary, size: 22),
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
          ...samples.map((item) {
            return Container(
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
                        item['sender'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        DateFormatter.formatShortDate(item['date'] as DateTime),
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
                      item['raw'] as String,
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
            );
          }),
        ],
      ),
    );
  }
}
