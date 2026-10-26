import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../transactions/views/widgets/add_transaction_sheet.dart';
import '../data/pending_alerts_provider.dart';
import 'widgets/pending_alert_card.dart';

class PendingAlertsScreen extends ConsumerWidget {
  const PendingAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAlerts = ref.watch(pendingAlertsProvider);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Needs Details'),
            const SizedBox(width: 8),
            if (pendingAlerts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.pending.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.pending.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  '${pendingAlerts.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pending,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: pendingAlerts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.income.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 48,
                        color: AppColors.income,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All caught up!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'All recent bank and MoMo alerts have been categorized.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: pendingAlerts.length,
              itemBuilder: (context, index) {
                final alert = pendingAlerts[index];
                return Dismissible(
                  key: Key(alert.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: AppColors.expense.withOpacity(0.8),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref
                        .read(pendingAlertsProvider.notifier)
                        .dismissAlert(alert.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alert dismissed'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: PendingAlertCard(
                    alert: alert,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) =>
                            AddTransactionSheet(initialTransaction: alert),
                      );
                    },
                    onQuickCategorize: (category) {
                      ref
                          .read(pendingAlertsProvider.notifier)
                          .categorizeAndConfirm(
                            alertId: alert.id,
                            category: category,
                            type: TransactionType.expense,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Saved as $category!'),
                          backgroundColor: palette.surface,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onDismiss: () {
                      ref
                          .read(pendingAlertsProvider.notifier)
                          .dismissAlert(alert.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}
