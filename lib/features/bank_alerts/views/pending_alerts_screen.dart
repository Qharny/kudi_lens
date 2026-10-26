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
            const Text(
              'Needs Details',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            if (pendingAlerts.isNotEmpty)
              Text(
                '(${pendingAlerts.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: palette.textSecondary,
                ),
              ),
          ],
        ),
      ),
      body: pendingAlerts.isEmpty
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 64,
                      color: palette.textPrimary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'All Caught Up!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Every bank alert and MoMo notification has been categorized. Your spend ledger is completely up to date.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AddTransactionSheet(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Record Manual Expense',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 40),
              itemCount: pendingAlerts.length,
              itemBuilder: (context, index) {
                final alert = pendingAlerts[index];
                return Dismissible(
                  key: Key(alert.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.expense,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Dismiss',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.delete_outline_rounded,
                            color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                  onDismissed: (_) {
                    ref
                        .read(pendingAlertsProvider.notifier)
                        .dismissAlert(alert.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Alert dismissed from inbox'),
                        backgroundColor: palette.surface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
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
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

