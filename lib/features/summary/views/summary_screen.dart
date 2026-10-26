import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../bank_alerts/data/pending_alerts_provider.dart';
import '../../transactions/data/transaction_provider.dart';
import 'widgets/spend_donut_chart.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  int _selectedDays = 7; // 1 = Today, 7 = Week, 30 = Month

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final totalFees = ref.watch(totalBankFeesProvider);
    final totalTransfers = ref.watch(totalTransfersProvider);
    final totalIncome = ref.watch(totalIncomeProvider);
    final periodSpend = ref.watch(periodSpendingProvider(_selectedDays));
    final pendingCount = ref.watch(pendingAlertsCountProvider);

    final filteredTxs = transactions.where((tx) {
      if (_selectedDays == 1) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
        return txDate == today;
      }
      final cutoff = DateTime.now().subtract(Duration(days: _selectedDays));
      return tx.date.isAfter(cutoff);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Analytics & Summaries'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period Selector Pills
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildPeriodPill(1, 'Today'),
                  _buildPeriodPill(7, 'Past 7 Days'),
                  _buildPeriodPill(30, 'Past 30 Days'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Honest Metrics Grid: Spending, Income, Fees, Transfers
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Net Spending',
                    amount: periodSpend,
                    accentColor: AppColors.expense,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Total Income',
                    amount: totalIncome,
                    accentColor: AppColors.income,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Bank Fees',
                    amount: totalFees,
                    accentColor: AppColors.fee,
                    icon: Icons.receipt_long_rounded,
                    subtitle: 'Charges & Levies',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Wallet Transfers',
                    amount: totalTransfers,
                    accentColor: AppColors.transfer,
                    icon: Icons.swap_horiz_rounded,
                    subtitle: 'Between Accounts',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pending Alert Honesty Banner
            if (pendingCount > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.pending.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.pending.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.pending),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Totals exclude $pendingCount pending bank alerts awaiting classification.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Spending Breakdown Heading
            const Text(
              'Spending by Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 12),

            // Donut Chart & Category Breakdown
            SpendDonutChart(transactions: filteredTxs),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodPill(int days, String label) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDays = days),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondaryDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required double amount,
    required Color accentColor,
    required IconData icon,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMutedDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
