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

    Color amountColor;
    String prefix;

    if (isIncome) {
      amountColor = AppColors.income;
      prefix = '+';
    } else if (isFee) {
      amountColor = AppColors.fee;
      prefix = '-';
    } else if (isTransfer) {
      amountColor = AppColors.transfer;
      prefix = '→';
    } else {
      amountColor = context.palette.textPrimary;
      prefix = '-';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Category / Type Icon with colored surface
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isFee
                      ? AppColors.fee.withOpacity(0.12)
                      : isTransfer
                          ? AppColors.transfer.withOpacity(0.12)
                          : isIncome
                              ? AppColors.income.withOpacity(0.12)
                              : category.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFee
                      ? Icons.receipt_long_rounded
                      : isTransfer
                          ? Icons.swap_horiz_rounded
                          : isIncome
                              ? Icons.arrow_downward_rounded
                              : category.icon,
                  color: isFee
                      ? AppColors.fee
                      : isTransfer
                          ? AppColors.transfer
                          : isIncome
                              ? AppColors.income
                              : category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Subtitle
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (transaction.source == TransactionSource.bankAlert) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Auto',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          DateFormatter.formatTime(transaction.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.palette.textMuted,
                          ),
                        ),
                        if (transaction.category != null &&
                            transaction.merchant != null) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.palette.textMuted,
                            ),
                          ),
                          Text(
                            transaction.category!,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.palette.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Amount & Direction indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$prefix${CurrencyFormatter.format(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                  if (transaction.status.isPending) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.pending.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Needs details',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.pending,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
