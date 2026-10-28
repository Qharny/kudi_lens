import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bank_alerts/data/alert_channel.dart';
import '../../bank_alerts/views/unrecognised_alerts_screen.dart';
import '../../onboarding/views/onboarding_screen.dart';
import '../../rules/views/rules_manager_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  /// Also read natively by AlertListenerService ("flutter.auto_track_alerts").
  static const _autoTrackKey = 'auto_track_alerts';
  static const _alertChannel = AlertChannel();

  bool _autoTrackAlerts = false;
  bool _listenerEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAlertTrackingState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check after the user returns from the system permission screen.
    if (state == AppLifecycleState.resumed) _loadAlertTrackingState();
  }

  Future<void> _loadAlertTrackingState() async {
    final prefs = await SharedPreferences.getInstance();
    var listenerEnabled = false;
    try {
      listenerEnabled = await _alertChannel.isListenerEnabled();
    } on MissingPluginException {
      // No native listener (tests, non-Android).
    }
    if (!mounted) return;
    setState(() {
      _autoTrackAlerts = prefs.getBool(_autoTrackKey) ?? false;
      _listenerEnabled = listenerEnabled;
    });
  }

  Future<void> _setAutoTrack(bool value) async {
    setState(() => _autoTrackAlerts = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoTrackKey, value);
    if (value && !_listenerEnabled) await _alertChannel.openListenerSettings();
  }
  final Set<String> _trackedProviders = {
    'calbank',
    'gcb',
    'ecobank',
    'stanbic',
    'absa',
    'fidelity',
    'mtn_momo',
    'telecel',
    'at_money',
  };

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
            onChanged: _setAutoTrack,
          ),
          if (_autoTrackAlerts && !_listenerEnabled && _alertChannel.isSupported)
            ListTile(
              leading: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.pending),
              title: Text('Grant notification access',
                  style: TextStyle(color: palette.textPrimary)),
              subtitle: Text(
                  'Kudi Lens can\'t see bank alerts until access is granted',
                  style: TextStyle(fontSize: 12, color: palette.textSecondary)),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: palette.textMuted),
              onTap: _alertChannel.openListenerSettings,
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
          _buildProviderToggle('calbank', 'CalBank Ghana', 'Debit alerts & CalPay notifications', palette),
          _buildProviderToggle('gcb', 'GCB Bank', 'Ghana Commercial Bank SMS & in-app alerts', palette),
          _buildProviderToggle('ecobank', 'Ecobank Ghana', 'Ecobank debit alerts & OmniLite transactions', palette),
          _buildProviderToggle('stanbic', 'Stanbic Bank Ghana', 'Stanbic alert notifications & transfers', palette),
          _buildProviderToggle('absa', 'Absa Bank Ghana', 'Absa debit alerts & digital payments', palette),
          _buildProviderToggle('fidelity', 'Fidelity Bank Ghana', 'Fidelity smart alerts & POS transactions', palette),
          _buildProviderToggle('mtn_momo', 'MTN Mobile Money (MoMo)', 'Merchant payments, transfers & cash-outs', palette),
          _buildProviderToggle('telecel', 'Telecel Cash', 'Wallet payments and airtime purchases', palette),
          _buildProviderToggle('at_money', 'AT Money (AirtelTigo)', 'AT wallet transactions & cash transfers', palette),
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
          ListTile(
            leading: Icon(Icons.explore_outlined, color: palette.textPrimary),
            title: Text('App Tour & Onboarding',
                style: TextStyle(color: palette.textPrimary)),
            subtitle: Text('Revisit the feature guide & privacy walkthrough',
                style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            trailing: Icon(Icons.chevron_right_rounded,
                color: palette.textMuted),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(),
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
          // About Section with App Logo
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kudi Lens',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Version 1.0.0 • Offline Bank Alert Tracker',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: palette.textSecondary,
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

  Widget _buildProviderToggle(
      String providerKey, String title, String subtitle, AppPalette palette) {
    final isTracked = _trackedProviders.contains(providerKey);
    return CheckboxListTile(
      title: Text(title,
          style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: palette.textSecondary)),
      value: isTracked,
      activeColor: AppColors.primary,
      onChanged: (val) {
        setState(() {
          if (val == true) {
            _trackedProviders.add(providerKey);
          } else {
            _trackedProviders.remove(providerKey);
          }
        });
      },
    );
  }
}
