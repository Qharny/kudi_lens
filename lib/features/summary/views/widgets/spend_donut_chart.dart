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
    final palette = context.palette;

    // Only aggregate expenses (excluding transfers & income)
    final expenses = widget.transactions
        .where((tx) =>
            tx.type == TransactionType.expense || tx.type == TransactionType.fee)
        .toList();

    if (expenses.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.border, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline_rounded,
                size: 36, color: palette.textMuted),
            const SizedBox(height: 8),
            Text(
              'No expenses recorded for this period',
              style: TextStyle(
                color: palette.textSecondary,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
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
        // Cartoon Chart Card Container
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: palette.border, width: 1.5),
            boxShadow: palette.cardShadow,
          ),
          child: SizedBox(
            height: 210,
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
                    sectionsSpace: 4,
                    centerSpaceRadius: 65,
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
                // Center 3D Badge
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(palette.isDark ? 0.3 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TOTAL SPENT',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 0.5,
                          color: palette.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        CurrencyFormatter.formatCompact(totalSpend),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Ranked Category List as Tactile Cartoon Pills
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final cat = CategoryItem.findByName(entry.key);
            final percent = totalSpend > 0 ? (entry.value / totalSpend) * 100 : 0.0;
            final fraction = totalSpend > 0 ? (entry.value / totalSpend).clamp(0.0, 1.0) : 0.0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: palette.border,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(palette.isDark ? 0.18 : 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(cat.icon, size: 24, color: palette.textPrimary),
                  const SizedBox(width: 14),

                  // Name & Progress meter capsule
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: palette.textPrimary,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(entry.value),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.3,
                                color: palette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        // Clean solid progress bar (No gradient, No glow)
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: palette.isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: fraction,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: cat.color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Percentage Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cat.color.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cat.color,
                      ),
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

