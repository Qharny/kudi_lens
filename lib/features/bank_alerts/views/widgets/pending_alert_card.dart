import 'package:flutter/material.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class PendingAlertCard extends StatelessWidget {
  final TransactionItem alert;
  final VoidCallback onTap;
  final Function(String category) onQuickCategorize;
  final VoidCallback onDismiss;

  const PendingAlertCard({
    super.key,
    required this.alert,
    required this.onTap,
    required this.onQuickCategorize,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Top 4 quick suggestion categories
    final quickCategories = [
      'Food & Dining',
      'Transport',
      'Shopping',
      'Data & Airtime',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.pending.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Source badge & time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.pending.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                size: 12,
                                color: AppColors.pending,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                alert.accountId == 'acc_calbank'
                                    ? 'CalBank Alert'
                                    : 'MTN MoMo Alert',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pending,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.formatTime(alert.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textMutedDark,
                      ),
                      onPressed: onDismiss,
                      tooltip: 'Dismiss alert',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount
                Text(
                  CurrencyFormatter.format(alert.amount),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 6),

                // Bank Info / Narration pill
                if (alert.narration != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorderDark),
                    ),
                    child: Text(
                      'Info: ${alert.narration}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),

                // Prompt & Quick Categorize Chips
                const Text(
                  'What was this for?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...quickCategories.map((catName) {
                      final cat = CategoryItem.findByName(catName);
                      return ActionChip(
                        avatar: Icon(cat.icon, size: 14, color: cat.color),
                        label: Text(
                          cat.name.split(' ').first,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cat.color,
                          ),
                        ),
                        backgroundColor: cat.color.withOpacity(0.12),
                        side: BorderSide(
                          color: cat.color.withOpacity(0.25),
                        ),
                        onPressed: () => onQuickCategorize(cat.name),
                      );
                    }),
                    ActionChip(
                      avatar: const Icon(
                        Icons.more_horiz_rounded,
                        size: 14,
                        color: AppColors.textSecondaryDark,
                      ),
                      label: const Text(
                        'More...',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      backgroundColor: AppColors.cardDark,
                      side: const BorderSide(color: AppColors.cardBorderDark),
                      onPressed: onTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
