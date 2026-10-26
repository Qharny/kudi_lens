import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class SpendDonutChart extends StatefulWidget {
  final List<TransactionItem> transactions;

  const SpendDonutChart({
    super.key,
    required this.transactions,
  });

  @override
  State<SpendDonutChart> createState() => _SpendDonutChartState();
}

class _SpendDonutChartState extends State<SpendDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Only aggregate expenses (excluding transfers & income)
    final expenses = widget.transactions
        .where((tx) =>
            tx.type == TransactionType.expense || tx.type == TransactionType.fee)
        .toList();

    if (expenses.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          'No spending recorded for this period',
          style: TextStyle(color: AppColors.textMutedDark),
        ),
      );
    }

    final Map<String, double> categoryTotals = {};
    for (final tx in expenses) {
      final cat = tx.category ?? 'Other';
      categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + tx.amount;
    }

    final totalSpend =
        categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 60,
                  sections: List.generate(entries.length, (i) {
                    final isTouched = i == _touchedIndex;
                    final radius = isTouched ? 28.0 : 20.0;
                    final entry = entries[i];
                    final cat = CategoryItem.findByName(entry.key);

                    return PieChartSectionData(
                      color: cat.color,
                      value: entry.value,
                      title: '',
                      radius: radius,
                    );
                  }),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Spent',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMutedDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatCompact(totalSpend),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Ranked Category List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final cat = CategoryItem.findByName(entry.key);
            final percent = totalSpend > 0 ? (entry.value / totalSpend) * 100 : 0.0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorderDark),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(cat.icon, size: 16, color: cat.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  Text(
                    '${percent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    CurrencyFormatter.format(entry.value),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
