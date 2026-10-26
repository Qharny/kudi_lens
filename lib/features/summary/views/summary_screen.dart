import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../bank_alerts/data/pending_alerts_provider.dart';
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
    final palette = context.palette;

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
      backgroundColor: palette.bg,
      appBar: AppBar(
        title: const Text(
          'Analytics & Summaries',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period Selector Switch
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.border, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(palette.isDark ? 0.2 : 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildPeriodPill(1, 'Today', palette),
                  _buildPeriodPill(7, 'Past 7 Days', palette),
                  _buildPeriodPill(30, 'Past 30 Days', palette),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Honest Metrics Grid: 4 Clean Blocks
            Row(
              children: [
                Expanded(
                  child: _buildMetricBlock(
                    palette: palette,
                    title: 'Net Spending',
                    amount: periodSpend,
                    accentColor: AppColors.expense,
                    icon: Icons.trending_down_rounded,
                    tagText: 'Real Outflow',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBlock(
                    palette: palette,
                    title: 'Total Income',
                    amount: totalIncome,
                    accentColor: AppColors.income,
                    icon: Icons.trending_up_rounded,
                    tagText: 'Inflows',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricBlock(
                    palette: palette,
                    title: 'Bank Fees',
                    amount: totalFees,
                    accentColor: AppColors.fee,
                    icon: Icons.receipt_long_rounded,
                    tagText: 'Charges & E-Levy',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBlock(
                    palette: palette,
                    title: 'Wallet Transfers',
                    amount: totalTransfers,
                    accentColor: AppColors.transfer,
                    icon: Icons.swap_horiz_rounded,
                    tagText: 'Internal Legs',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pending Alert Honesty Banner
            if (pendingCount > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.pending.withOpacity(0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(palette.isDark ? 0.2 : 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded,
                        size: 20, color: palette.textPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Metrics exclude $pendingCount unfiled alerts awaiting your classification.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Spending Breakdown Heading with clean badge
            Row(
              children: [
                Icon(
                  Icons.pie_chart_rounded,
                  size: 20,
                  color: palette.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Spending by Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: palette.textPrimary,
                  ),
                ),
              ],
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

  Widget _buildPeriodPill(int days, String label, AppPalette palette) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDays = days),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBlock({
    required AppPalette palette,
    required String title,
    required double amount,
    required Color accentColor,
    required IconData icon,
    required String tagText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 22, color: palette.textPrimary),
              Text(
                tagText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

