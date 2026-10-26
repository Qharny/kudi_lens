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
          title: Text(
            'Add Account / Wallet',
            style: TextStyle(color: palette.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedProvider,
                  dropdownColor: palette.surface,
                  decoration: const InputDecoration(labelText: 'Provider'),
                  items: const [
                    DropdownMenuItem(
                        value: 'calbank', child: Text('CalBank')),
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
                  decoration: const InputDecoration(
                    labelText: 'Account Name (e.g. Current A/C)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: numberController,
                  style: TextStyle(color: palette.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Masked Number (e.g. 140***721)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: balanceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: palette.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Current Balance (GHS)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
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
              child: const Text('Add'),
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
        title: const Text('Accounts & Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddAccountDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Total Balance Header Tile
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Combined Liquidity',
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All Wallets',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormatter.format(totalBalance),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Accounts List
          ...accounts.map(
            (acc) => AccountCard(
              account: acc,
              onTap: () {
                _showBalanceUpdateDialog(context, ref, acc);
              },
            ),
          ),

          // Reconciliation explanation card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Balances are automatically reconciled directly from your bank debit and credit notifications.',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
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
        title: Text(
          'Adjust ${account.name} Balance',
          style: TextStyle(color: palette.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: palette.textPrimary),
          decoration: const InputDecoration(
            labelText: 'New Balance (GHS)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
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
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
