import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bank_alerts/views/unrecognised_alerts_screen.dart';
import '../../rules/views/rules_manager_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoTrackAlerts = true;
  bool _trackCalBank = true;
  bool _trackMtnMomo = true;
  bool _trackTelecel = false;

  void _showBatteryOptimizationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Background Battery Exemption'),
        content: const Text(
          'To ensure bank alerts are received without delay, please exempt Kudi Lens from battery optimization in your device settings.\n\nRecommended for Samsung, Tecno, Infinix, and Xiaomi devices.',
          style: TextStyle(
            color: AppColors.textSecondaryDark,
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Section: Alert Tracking
          _buildSectionHeader('AUTOMATED BANK ALERT TRACKING'),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_active_rounded,
                  color: AppColors.primaryLight, size: 20),
            ),
            title: const Text('Auto-track bank alerts',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text(
                'Read debit/credit notifications via Notification Listener service',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            value: _autoTrackAlerts,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _autoTrackAlerts = val),
          ),
          ListTile(
            leading: const Icon(Icons.battery_charging_full_rounded,
                color: AppColors.textSecondaryDark),
            title: const Text('Battery Optimization Guide'),
            subtitle: const Text('Ensure background listener stays alive',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMutedDark),
            onTap: _showBatteryOptimizationDialog,
          ),
          const Divider(indent: 16, endIndent: 16),

          // Section: Supported Providers
          _buildSectionHeader('TRACKED PROVIDERS'),
          CheckboxListTile(
            title: const Text('CalBank Ghana'),
            subtitle: const Text('SMS & in-app debit notifications',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            value: _trackCalBank,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _trackCalBank = val ?? false),
          ),
          CheckboxListTile(
            title: const Text('MTN Mobile Money (MoMo)'),
            subtitle: const Text('Merchant payments & pull-transfers',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            value: _trackMtnMomo,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _trackMtnMomo = val ?? false),
          ),
          CheckboxListTile(
            title: const Text('Telecel Cash'),
            subtitle: const Text('Wallet payments and airtime',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            value: _trackTelecel,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _trackTelecel = val ?? false),
          ),
          const Divider(indent: 16, endIndent: 16),

          // Section: Intelligence & Rules
          _buildSectionHeader('INTELLIGENCE & PARSING'),
          ListTile(
            leading: const Icon(Icons.psychology_rounded,
                color: AppColors.primaryLight),
            title: const Text('Learned Categorization Rules'),
            subtitle: const Text('Review patterns the app learned from you',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMutedDark),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RulesManagerScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.mark_email_unread_rounded,
                color: AppColors.pending),
            title: const Text('Unrecognised Alerts'),
            subtitle: const Text('View financial alerts that didn\'t match templates',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMutedDark),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UnrecognisedAlertsScreen(),
                ),
              );
            },
          ),
          const Divider(indent: 16, endIndent: 16),

          // Section: Privacy & Security
          _buildSectionHeader('SECURITY & DATA PRIVACY'),
          ListTile(
            leading: const Icon(Icons.lock_rounded, color: AppColors.income),
            title: const Text('On-Device Encryption'),
            subtitle: const Text('AES-256 encrypted storage via Hive CE & Keystore',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.income.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.income,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined,
                color: AppColors.textSecondaryDark),
            title: const Text('Export Data'),
            subtitle: const Text('Download transactions as CSV / JSON',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting transactions as CSV...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded,
                color: AppColors.expense),
            title: const Text('Wipe All Local Data',
                style: TextStyle(color: AppColors.expense)),
            subtitle: const Text('Erase all stored transactions, rules, and accounts',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceDark,
                  title: const Text('Erase All Data?'),
                  content: const Text(
                    'This action will permanently delete all transaction records and learned rules. It cannot be undone.',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All data cleared.')),
                        );
                      },
                      child: const Text('Erase',
                          style: TextStyle(color: AppColors.expense)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textMutedDark,
        ),
      ),
    );
  }
}
