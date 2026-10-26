import 'package:flutter/material.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem transaction;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = CategoryItem.findByName(transaction.category);
    final isIncome = transaction.type == TransactionType.income;
    final isFee = transaction.type == TransactionType.fee;
    final isTransfer = transaction.type == TransactionType.transfer;
    final palette = context.palette;

    IconData displayIcon;
    String prefix;

    if (isIncome) {
      prefix = '+';
      displayIcon = Icons.arrow_downward_rounded;
    } else if (isFee) {
      prefix = '-';
      displayIcon = Icons.receipt_long_rounded;
    } else if (isTransfer) {
      prefix = '-';
      displayIcon = Icons.swap_horiz_rounded;
    } else {
      prefix = '-';
      displayIcon = category.icon;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.isDark
                ? Colors.black.withOpacity(0.2)
                : const Color(0xFF64748B).withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  displayIcon,
                  color: palette.textPrimary,
                  size: 24,
                ),
                const SizedBox(width: 14),

                // Title and Subtitle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.merchant ??
                            transaction.category ??
                            transaction.narration ??
                            transaction.type.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (transaction.source == TransactionSource.bankAlert) ...[
                            Icon(
                              Icons.bolt_rounded,
                              size: 13,
                              color: palette.textPrimary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Auto',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: palette.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            DateFormatter.formatTime(transaction.date),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: palette.textMuted,
                            ),
                          ),
                          if (transaction.category != null) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 11,
                                color: palette.textMuted,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                transaction.category!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$prefix${CurrencyFormatter.format(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isIncome
                            ? AppColors.income
                            : isFee
                                ? AppColors.fee
                                : isTransfer
                                    ? AppColors.transfer
                                    : palette.textPrimary,
                      ),
                    ),
                    if (transaction.status.isPending) ...[
                      const SizedBox(height: 2),
                      const Text(
                        'Needs details',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pending,
                        ),
                      ),
                    ],
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

