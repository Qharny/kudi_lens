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
    final palette = context.palette;
    final isCalBank = alert.accountId == 'acc_calbank';
    final providerName = isCalBank ? 'CalBank Alert' : 'MTN MoMo Alert';

    final quickCategories = [
      'Food & Dining',
      'Transport',
      'Shopping',
      'Data & Airtime',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.pending.withOpacity(0.4),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Provider Badge & Time & Dismiss
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 15,
                          color: palette.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          providerName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          DateFormatter.formatTime(alert.date),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: palette.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onDismiss,
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.format(alert.amount),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'DEBIT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.expense,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Monospace narration ticket box
                if (alert.narration != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: palette.border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 14,
                          color: palette.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            alert.narration!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'monospace',
                              color: palette.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),

                // Categorize Prompt
                Text(
                  'TAP TO CATEGORIZE IN 1-CLICK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Clean Quick Buttons (No gradients, No glow)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...quickCategories.map((catName) {
                      final cat = CategoryItem.findByName(catName);
                      return _CartoonQuickButton(
                        label: cat.name.split(' ').first,
                        icon: cat.icon,
                        color: cat.color,
                        onTap: () => onQuickCategorize(cat.name),
                      );
                    }),
                    _CartoonQuickButton(
                      label: 'More...',
                      icon: Icons.tune_rounded,
                      color: palette.textSecondary,
                      isOutlined: true,
                      onTap: onTap,
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

class _CartoonQuickButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isOutlined;

  const _CartoonQuickButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isOutlined
                ? palette.card
                : color.withOpacity(palette.isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOutlined ? palette.border : color.withOpacity(0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: palette.textPrimary),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isOutlined ? palette.textPrimary : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


