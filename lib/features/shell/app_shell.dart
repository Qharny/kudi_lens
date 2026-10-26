import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../accounts/views/accounts_screen.dart';
import '../bank_alerts/data/pending_alerts_provider.dart';
import '../settings/views/settings_screen.dart';
import '../summary/views/summary_screen.dart';
import '../transactions/views/home_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pendingCount = ref.watch(pendingAlertsCountProvider);
    final palette = context.palette;

    final screens = [
      HomeScreen(
        onNavigateToAccounts: () => setState(() => _currentIndex = 2),
      ),
      const SummaryScreen(),
      const AccountsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: palette.bg,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: palette.border,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.isDark
                    ? Colors.black.withOpacity(0.4)
                    : const Color(0xFF1E293B).withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCartoonNavItem(
                index: 0,
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet_rounded,
                label: 'Home',
                badgeCount: pendingCount,
                palette: palette,
              ),
              _buildCartoonNavItem(
                index: 1,
                icon: Icons.pie_chart_outline_rounded,
                activeIcon: Icons.pie_chart_rounded,
                label: 'Analytics',
                palette: palette,
              ),
              _buildCartoonNavItem(
                index: 2,
                icon: Icons.credit_card_outlined,
                activeIcon: Icons.credit_card_rounded,
                label: 'Wallets',
                palette: palette,
              ),
              _buildCartoonNavItem(
                index: 3,
                icon: Icons.tune_rounded,
                activeIcon: Icons.tune_rounded,
                label: 'Settings',
                palette: palette,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartoonNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required AppPalette palette,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.35)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : palette.textMuted,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.pending,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: palette.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
