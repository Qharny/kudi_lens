import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../accounts/data/account_provider.dart';
import '../../bank_alerts/data/pending_alerts_provider.dart';
import '../../bank_alerts/views/pending_alerts_screen.dart';
import '../data/transaction_provider.dart';
import 'transaction_detail_screen.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/attention_banner.dart';
import 'widgets/balance_card.dart';
import 'widgets/transaction_tile.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToAccounts;

  const HomeScreen({
    super.key,
    required this.onNavigateToAccounts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(recentTransactionsProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final todaySpend = ref.watch(todaySpendingProvider);
    final accounts = ref.watch(accountProvider);
    final pendingCount = ref.watch(pendingAlertsCountProvider);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: palette.textPrimary,
              size: 26,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Kudi Lens',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• OFFLINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: palette.textMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Pocket Spend Tracker',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Pending alerts bell with clean badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: palette.textPrimary,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PendingAlertsScreen(),
                    ),
                  );
                },
              ),
              if (pendingCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.pending,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Attention Banner when alerts are waiting
          SliverToBoxAdapter(
            child: AttentionBanner(
              pendingCount: pendingCount,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PendingAlertsScreen(),
                  ),
                );
              },
            ),
          ),

          // Realistic Cartoon Balance Card
          SliverToBoxAdapter(
            child: BalanceCard(
              totalBalance: totalBalance,
              todaySpending: todaySpend,
              accounts: accounts,
              onManageAccounts: onNavigateToAccounts,
            ),
          ),

          // Recent Activity Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 20,
                        color: palette.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: palette.border, width: 1),
                    ),
                    child: Text(
                      '${transactions.length} items',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transactions List or Empty State
          if (transactions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: palette.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: palette.border, width: 1.5),
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 34,
                          color: palette.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Transactions Yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap the button below or wait for bank SMS alerts to automatically log your spend.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tx = transactions[index];
                  return TransactionTile(
                    transaction: tx,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TransactionDetailScreen(transactionId: tx.id),
                        ),
                      );
                    },
                  );
                },
                childCount: transactions.length,
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 90),
          ),
        ],
      ),
      // Clean Solid Floating Action Button (No gradient, No colored glow)
      floatingActionButton: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddTransactionSheet(),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Text(
                'Record Spend',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
