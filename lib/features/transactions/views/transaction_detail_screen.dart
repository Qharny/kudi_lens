import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../accounts/data/account_provider.dart';
import '../data/transaction_provider.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/category_badge.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final tx = transactions.firstWhere(
      (item) => item.id == transactionId,
      orElse: () => const TransactionItem(
        id: '',
        amount: 0,
        type: TransactionType.expense,
        date: null as dynamic,
      ),
    );

    if (tx.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final accounts = ref.watch(accountProvider);
    final account = accounts.where((a) => a.id == tx.accountId).firstOrNull;
    final category = CategoryItem.findByName(tx.category);

    final isIncome = tx.type == TransactionType.income;
    final isFee = tx.type == TransactionType.fee;
    final isTransfer = tx.type == TransactionType.transfer;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTransactionSheet(initialTransaction: tx),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.expense),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceDark,
                  title: const Text('Delete Transaction?'),
                  content: const Text(
                    'Are you sure you want to remove this transaction record?',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(transactionProvider.notifier)
                            .deleteTransaction(tx.id);
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: AppColors.expense)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Amount & Direction
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorderDark),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFee
                          ? AppColors.fee.withOpacity(0.15)
                          : isTransfer
                              ? AppColors.transfer.withOpacity(0.15)
                              : isIncome
                                  ? AppColors.income.withOpacity(0.15)
                                  : category.color.withOpacity(0.15),
                      shape: BoxShape.circle,
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
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    CurrencyFormatter.format(tx.amount),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CategoryBadge(categoryName: tx.category ?? 'Unclassified'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: tx.source == TransactionSource.bankAlert
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: tx.source == TransactionSource.bankAlert
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.cardBorderDark,
                          ),
                        ),
                        child: Text(
                          tx.source.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tx.source == TransactionSource.bankAlert
                                ? AppColors.primaryLight
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metadata card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorderDark),
              ),
              child: Column(
                children: [
                  _buildPropertyRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date & Time',
                    value: DateFormatter.formatFull(tx.date),
                  ),
                  const Divider(height: 1, indent: 50),
                  _buildPropertyRow(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Account',
                    value: account != null
                        ? '${account.name} (${account.maskedNumber})'
                        : 'Unassigned',
                  ),
                  if (tx.merchant != null) ...[
                    const Divider(height: 1, indent: 50),
                    _buildPropertyRow(
                      icon: Icons.storefront_rounded,
                      label: 'Merchant / Recipient',
                      value: tx.merchant!,
                    ),
                  ],
                  if (tx.location != null) ...[
                    const Divider(height: 1, indent: 50),
                    _buildPropertyRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location / Terminal',
                      value: tx.location!,
                    ),
                  ],
                  if (tx.balanceAfter != null) ...[
                    const Divider(height: 1, indent: 50),
                    _buildPropertyRow(
                      icon: Icons.account_balance_rounded,
                      label: 'Balance After',
                      value: CurrencyFormatter.format(tx.balanceAfter!),
                      valueColor: AppColors.primaryLight,
                    ),
                  ],
                  if (tx.note != null && tx.note!.isNotEmpty) ...[
                    const Divider(height: 1, indent: 50),
                    _buildPropertyRow(
                      icon: Icons.notes_rounded,
                      label: 'Note',
                      value: tx.note!,
                    ),
                  ],
                ],
              ),
            ),

            // Linked Transfer or Fee Leg if present
            if (tx.linkedTransactionId != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.transfer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.transfer.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      color: AppColors.transfer,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Linked Transfer Leg',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.transfer,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Matched with internal wallet transfer. Excluded from spending total.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Raw Alert Message (Audit Trail)
            if (tx.rawMessage != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Original Bank Alert',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorderDark),
                ),
                child: Text(
                  tx.rawMessage!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMutedDark),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
