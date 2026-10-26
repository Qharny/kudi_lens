import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/account.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../data/account_provider.dart';
import 'widgets/account_card.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final balanceController = TextEditingController();
    String selectedProvider = 'calbank';
    final palette = context.palette;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: palette.border, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Add Wallet / Card',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedProvider,
                  dropdownColor: palette.surface,
                  decoration: InputDecoration(
                    labelText: 'Provider',
                    labelStyle: TextStyle(color: palette.textSecondary),
                    filled: true,
                    fillColor: palette.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: palette.border),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'calbank', child: Text('CalBank Ghana')),
                    DropdownMenuItem(
                        value: 'mtn_momo', child: Text('MTN MoMo')),
                    DropdownMenuItem(
                        value: 'telecel', child: Text('Telecel Cash')),
                    DropdownMenuItem(
                        value: 'cash', child: Text('Cash Wallet')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedProvider = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: palette.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Account Name (e.g. Salary A/C)',
                    labelStyle: TextStyle(color: palette.textSecondary),
                    filled: true,
                    fillColor: palette.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: palette.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: numberController,
                  style: TextStyle(color: palette.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Masked Number (e.g. 140***721)',
                    labelStyle: TextStyle(color: palette.textSecondary),
                    filled: true,
                    fillColor: palette.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: palette.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: balanceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: palette.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Current Balance (GHS)',
                    labelStyle: TextStyle(color: palette.textSecondary),
                    filled: true,
                    fillColor: palette.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: palette.border),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final balance =
                    double.tryParse(balanceController.text.trim()) ?? 0.0;
                final newAccount = Account(
                  id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim().isEmpty
                      ? 'New Account'
                      : nameController.text.trim(),
                  provider: selectedProvider,
                  maskedNumber: numberController.text.trim().isEmpty
                      ? 'N/A'
                      : numberController.text.trim(),
                  lastBalance: balance,
                  lastBalanceDate: DateTime.now(),
                );
                ref.read(accountProvider.notifier).addAccount(newAccount);
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text('Add Account',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        title: const Text(
          'Accounts & Wallets',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border, width: 1.2),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, size: 22),
              onPressed: () => _showAddAccountDialog(context, ref),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Total Balance Hero Vault Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.income.withOpacity(0.3),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.income,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TOTAL LIQUIDITY VAULT',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w800,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(totalBalance),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: AppColors.income,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.income.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.income.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${accounts.length} Wallets',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.income,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Accounts List
          ...accounts.map(
            (acc) => AccountCard(
              account: acc,
              onTap: () {
                _showBalanceUpdateDialog(context, ref, acc);
              },
            ),
          ),

          // Tactile Add Account Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAddAccountDialog(context, ref),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(palette.isDark ? 0.2 : 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Bank Account or MoMo Wallet',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Reconciliation explanation card as cartoon seal ticket
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.border, width: 1.4),
              boxShadow: palette.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Balances are automatically reconciled directly from your official bank debit and credit SMS alerts.',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showBalanceUpdateDialog(
      BuildContext context, WidgetRef ref, Account account) {
    final controller =
        TextEditingController(text: account.lastBalance.toStringAsFixed(2));
    final palette = context.palette;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: palette.border, width: 1.5),
        ),
        title: Text(
          'Adjust ${account.name} Balance',
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(
            labelText: 'New Balance (GHS)',
            labelStyle: TextStyle(color: palette.textSecondary),
            filled: true,
            fillColor: palette.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: palette.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: palette.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newBal = double.tryParse(controller.text.trim());
              if (newBal != null) {
                ref
                    .read(accountProvider.notifier)
                    .updateBalance(account.id, newBal);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

