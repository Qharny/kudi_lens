import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../accounts/data/account_provider.dart';
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
    final txList =
        transactions.where((item) => item.id == transactionId).toList();

    if (txList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final tx = txList.first;
    final accounts = ref.watch(accountProvider);
    final account = accounts.where((a) => a.id == tx.accountId).firstOrNull;
    final category = CategoryItem.findByName(tx.category);

    final isIncome = tx.type == TransactionType.income;
    final isFee = tx.type == TransactionType.fee;
    final isTransfer = tx.type == TransactionType.transfer;
    final primaryColor = isFee
        ? AppColors.fee
        : isTransfer
            ? AppColors.transfer
            : isIncome
                ? AppColors.income
                : category.color;

    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
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
                  backgroundColor: palette.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(color: palette.border, width: 1.5),
                  ),
                  title: Text(
                    'Delete Transaction?',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to remove this record from your expense history?',
                    style: TextStyle(color: palette.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: palette.textMuted),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(transactionProvider.notifier)
                            .deleteTransaction(tx.id);
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: AppColors.expense,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cartoon Digital Receipt Card
            Container(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: primaryColor.withOpacity(0.35),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(palette.isDark ? 0.25 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    // Top Receipt Header Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(palette.isDark ? 0.2 : 0.1),
                        border: Border(
                          bottom: BorderSide(
                            color: primaryColor.withOpacity(0.25),
                            width: 1.2,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tx.type.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Column(
                        children: [
                          Icon(
                            isFee
                                ? Icons.receipt_long_rounded
                                : isTransfer
                                    ? Icons.swap_horiz_rounded
                                    : isIncome
                                        ? Icons.arrow_downward_rounded
                                        : category.icon,
                            color: palette.textPrimary,
                            size: 38,
                          ),
                          const SizedBox(height: 14),

                          // Amount
                          Text(
                            CurrencyFormatter.format(tx.amount),
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -1,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Badges Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CategoryBadge(categoryName: tx.category ?? 'Unclassified'),
                              const SizedBox(width: 8),
                              Text(
                                '• ${tx.source.displayName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metadata Card
            Container(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: palette.border, width: 1.4),
                boxShadow: palette.cardShadow,
              ),
              child: Column(
                children: [
                  _buildPropertyRow(
                    palette: palette,
                    icon: Icons.calendar_today_rounded,
                    label: 'Date & Time',
                    value: DateFormatter.formatFull(tx.date),
                  ),
                  Divider(height: 1, indent: 52, color: palette.border),
                  _buildPropertyRow(
                    palette: palette,
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Account / Wallet',
                    value: account != null
                        ? '${account.name} (${account.maskedNumber})'
                        : 'Unassigned',
                  ),
                  if (tx.merchant != null) ...[
                    Divider(height: 1, indent: 52, color: palette.border),
                    _buildPropertyRow(
                      palette: palette,
                      icon: Icons.storefront_rounded,
                      label: 'Merchant / Recipient',
                      value: tx.merchant!,
                    ),
                  ],
                  if (tx.location != null) ...[
                    Divider(height: 1, indent: 52, color: palette.border),
                    _buildPropertyRow(
                      palette: palette,
                      icon: Icons.location_on_outlined,
                      label: 'Location / Terminal',
                      value: tx.location!,
                    ),
                  ],
                  if (tx.balanceAfter != null) ...[
                    Divider(height: 1, indent: 52, color: palette.border),
                    _buildPropertyRow(
                      palette: palette,
                      icon: Icons.account_balance_rounded,
                      label: 'Balance After Alert',
                      value: CurrencyFormatter.format(tx.balanceAfter!),
                      valueColor: AppColors.income,
                    ),
                  ],
                  if (tx.note != null && tx.note!.isNotEmpty) ...[
                    Divider(height: 1, indent: 52, color: palette.border),
                    _buildPropertyRow(
                      palette: palette,
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
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.transfer.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.transfer.withOpacity(0.3),
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      color: palette.textPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Linked Transfer Leg',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.transfer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Internal wallet transfer. Automatically excluded from net spending total.',
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.textSecondary,
                              height: 1.3,
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border, width: 1.4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.terminal_rounded,
                                size: 14, color: palette.textPrimary),
                            const SizedBox(width: 6),
                            const Text(
                              'ORIGINAL BANK ALERT AUDIT TRAIL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: tx.rawMessage!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied alert to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.copy_rounded,
                                  size: 13, color: palette.textPrimary),
                              const SizedBox(width: 4),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: palette.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tx.rawMessage!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: palette.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyRow({
    required AppPalette palette,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: palette.textPrimary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: palette.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: valueColor ?? palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

