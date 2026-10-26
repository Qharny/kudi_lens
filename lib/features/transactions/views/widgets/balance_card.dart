import 'package:flutter/material.dart';
import '../../../../core/models/account.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatefulWidget {
  final double totalBalance;
  final double todaySpending;
  final List<Account> accounts;
  final VoidCallback onManageAccounts;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.todaySpending,
    required this.accounts,
    required this.onManageAccounts,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _hideBalance = false;

  @override
  Widget build(BuildContext context) {
    // Primary account masked number or default
    final primaryAccount = widget.accounts.isNotEmpty ? widget.accounts.first : null;
    final maskedNum = primaryAccount != null && primaryAccount.maskedNumber != 'Cash'
        ? primaryAccount.maskedNumber
        : '1408 •••• •••• 7210';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Playful cartoon multi-layer drop shadow
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            // Vibrant realistic cartoon gradient
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2563EB), // Electric Royal Blue
                Color(0xFF1D4ED8), // Deep Blue
                Color(0xFF1E1B4B), // Midnight Indigo
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // --- Cartoon Decorative Background Shapes ---
              // Top-right glossy cartoon bubble
              Positioned(
                top: -35,
                right: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.22),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom-left playful translucent wave orb
              Positioned(
                bottom: -40,
                left: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF60A5FA).withOpacity(0.18),
                  ),
                ),
              ),
              // Top inner highlight sheen line
              Positioned(
                top: 0,
                left: 20,
                right: 20,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Foreground Content ---
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header: Chip, Contactless icon & Action Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Golden EMV Cartoon Chip
                            _buildCartoonChip(),
                            const SizedBox(width: 10),
                            // Contactless / NFC waves
                            RotatedBox(
                              quarterTurns: 1,
                              child: Icon(
                                Icons.wifi_rounded,
                                size: 20,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                        // Right Side: Wallets Button & Eye Toggle
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _hideBalance = !_hideBalance),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Icon(
                                  _hideBalance
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: widget.onManageAccounts,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Wallets',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Balance Header & Hero Digits
                    Text(
                      'AVAILABLE BALANCE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _hideBalance
                          ? '••••••••'
                          : CurrencyFormatter.format(widget.totalBalance),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.8,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Embossed Cartoon Card Number
                    Text(
                      maskedNum,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.5,
                        color: Colors.white.withOpacity(0.85),
                        shadows: const [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Bottom Row: Today's Spend badge & Dual Cartoon Circles Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Today's Spend Cartoon Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.arrow_downward_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Today: ${_hideBalance ? '••••' : CurrencyFormatter.formatCompact(widget.todaySpending)}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Cartoon Card Issuer Emblem (Overlapping Circles)
                        _buildCartoonCardBrand(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Cartoon EMV Smart Chip Widget ---
  Widget _buildCartoonChip() {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        // Shiny gold metallic gradient
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFE082), // Light Gold
            Color(0xFFFFB300), // Amber Gold
            Color(0xFFD97706), // Deep Gold
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xFF92400E).withOpacity(0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Engraved horizontal circuit track
          Positioned(
            left: 0,
            right: 0,
            top: 14,
            child: Container(
              height: 1,
              color: const Color(0xFF78350F).withOpacity(0.55),
            ),
          ),
          // Engraved left vertical circuit track
          Positioned(
            top: 0,
            bottom: 0,
            left: 13,
            child: Container(
              width: 1,
              color: const Color(0xFF78350F).withOpacity(0.55),
            ),
          ),
          // Engraved right vertical circuit track
          Positioned(
            top: 0,
            bottom: 0,
            right: 13,
            child: Container(
              width: 1,
              color: const Color(0xFF78350F).withOpacity(0.55),
            ),
          ),
          // Inner core micro-chip
          Center(
            child: Container(
              width: 14,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: const Color(0xFF78350F).withOpacity(0.6),
                  width: 0.9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Cartoon Dual Overlapping Circles (Card Brand) ---
  Widget _buildCartoonCardBrand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 42,
          height: 26,
          child: Stack(
            children: [
              // Left vibrant circle (Coral Red)
              Positioned(
                left: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEF4444).withOpacity(0.9),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Right vibrant circle (Warm Amber)
              Positioned(
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF59E0B).withOpacity(0.88),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'KUDI',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
