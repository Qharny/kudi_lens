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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Add Account / Wallet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedProvider,
                  dropdownColor: AppColors.cardDark,
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
                  decoration: const InputDecoration(
                    labelText: 'Account Name (e.g. Current A/C)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(
                    labelText: 'Masked Number (e.g. 140***721)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: balanceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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

    return Scaffold(
      backgroundColor: AppColors.bgDark,
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
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorderDark),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Combined Liquidity',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'All Wallets',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryDark,
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
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorderDark),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: AppColors.primaryLight,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Balances are automatically reconciled directly from your bank debit and credit notifications.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Adjust ${account.name} Balance'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
