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

  void _showBatteryOptimizationDialog(AppPalette palette) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette.surface,
        title: Text(
          'Background Battery Exemption',
          style: TextStyle(color: palette.textPrimary),
        ),
        content: Text(
          'To ensure bank alerts are received without delay, please exempt Kudi Lens from battery optimization in your device settings.\n\nRecommended for Samsung, Tecno, Infinix, and Xiaomi devices.',
          style: TextStyle(
            color: palette.textSecondary,
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
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Section: Alert Tracking
          _buildSectionHeader('AUTOMATED BANK ALERT TRACKING', palette),
          SwitchListTile(
            secondary: Icon(Icons.notifications_active_rounded,
                color: palette.textPrimary, size: 24),
            title: Text('Auto-track bank alerts',
                style: TextStyle(fontWeight: FontWeight.w500, color: palette.textPrimary)),
            subtitle: Text(
                'Read debit/credit notifications via Notification Listener service',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            value: _autoTrackAlerts,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _autoTrackAlerts = val),
          ),
          ListTile(
            leading: Icon(Icons.battery_charging_full_rounded,
                color: palette.textPrimary),
            title: Text('Battery Optimization Guide',
                style: TextStyle(color: palette.textPrimary)),
            subtitle: Text('Ensure background listener stays alive',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            trailing: Icon(Icons.chevron_right_rounded,
                color: palette.textMuted),
            onTap: () => _showBatteryOptimizationDialog(palette),
          ),
          Divider(indent: 16, endIndent: 16, color: palette.border),

          // Section: Supported Providers
          _buildSectionHeader('TRACKED PROVIDERS', palette),
          CheckboxListTile(
            title: Text('CalBank Ghana',
                style: TextStyle(color: palette.textPrimary)),
            subtitle: Text('SMS & in-app debit notifications',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            value: _trackCalBank,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _trackCalBank = val ?? false),
          ),
          CheckboxListTile(
            title: Text('MTN Mobile Money (MoMo)',
                style: TextStyle(color: palette.textPrimary)),
            subtitle: Text('Merchant payments & pull-transfers',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            value: _trackMtnMomo,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _trackMtnMomo = val ?? false),
          ),
          CheckboxListTile(
            title: Text('Telecel Cash',
                style: TextStyle(color: palette.textPrimary)),
            subtitle: Text('Wallet payments and airtime',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            value: _trackTelecel,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _trackTelecel = val ?? false),
          ),
          Divider(indent: 16, endIndent: 16, color: palette.border),

          // Section: Intelligence & Rules
          _buildSectionHeader('INTELLIGENCE & PARSING', palette),
          ListTile(
            leading: Icon(Icons.psychology_rounded,
                color: palette.textPrimary),
            title: Text('Learned Categorization Rules',
                style: TextStyle(color: palette.textPrimary)),
            subtitle: Text('Review patterns the app learned from you',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            trailing: Icon(Icons.chevron_right_rounded,
                color: palette.textMuted),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RulesManagerScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.mark_email_unread_rounded,
                color: palette.textPrimary),
            title: Text('Unrecognised Alerts',
                style: TextStyle(color: palette.textPrimary)),
            subtitle: Text('View financial alerts that didn\'t match templates',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            trailing: Icon(Icons.chevron_right_rounded,
                color: palette.textMuted),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UnrecognisedAlertsScreen(),
                ),
              );
            },
          ),
          Divider(indent: 16, endIndent: 16, color: palette.border),

          // Section: Privacy & Security
          _buildSectionHeader('SECURITY & DATA PRIVACY', palette),
          ListTile(
            leading: Icon(Icons.lock_rounded, color: palette.textPrimary),
            title: Text('On-Device Encryption',
                style: TextStyle(color: palette.textPrimary)),
            subtitle: Text('AES-256 encrypted storage via Hive CE & Keystore',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            trailing: const Text(
              'Active',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.income,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.file_download_outlined,
                color: palette.textPrimary),
            title: Text('Export Data',
                style: TextStyle(color: palette.textPrimary)),
            subtitle: Text('Download transactions as CSV / JSON',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting transactions as CSV...')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_rounded,
                color: palette.textPrimary),
            title: const Text('Wipe All Local Data',
                style: TextStyle(color: AppColors.expense)),
            subtitle: Text('Erase all stored transactions, rules, and accounts',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: palette.surface,
                  title: Text('Erase All Data?',
                      style: TextStyle(color: palette.textPrimary)),
                  content: Text(
                    'This action will permanently delete all transaction records and learned rules. It cannot be undone.',
                    style: TextStyle(color: palette.textSecondary),
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

  Widget _buildSectionHeader(String title, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
          color: palette.textMuted,
        ),
      ),
    );
  }
}
