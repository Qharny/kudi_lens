import 'package:flutter/material.dart';
import '../../../../core/models/account.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Unique cartoon styling tailored to provider
    LinearGradient cardGradient;
    Color chipColor;
    String providerLabel;
    Widget providerIconWidget;

    switch (account.provider) {
      case 'calbank':
        cardGradient = const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        chipColor = const Color(0xFFFFB300);
        providerLabel = 'CALBANK';
        providerIconWidget = _buildMiniChip(chipColor);
        break;
      case 'mtn_momo':
        cardGradient = const LinearGradient(
          colors: [Color(0xFFFFC000), Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        chipColor = Colors.black87;
        providerLabel = 'MTN MoMo';
        providerIconWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'MoMo',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFC000),
            ),
          ),
        );
        break;
      case 'telecel':
        cardGradient = const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFF991B1B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        chipColor = Colors.white;
        providerLabel = 'TELECEL';
        providerIconWidget = const Icon(Icons.contactless_rounded, color: Colors.white, size: 22);
        break;
      case 'cash':
      default:
        cardGradient = const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857), Color(0xFF064E3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        chipColor = Colors.white;
        providerLabel = 'CASH WALLET';
        providerIconWidget = const Icon(Icons.payments_rounded, color: Colors.white, size: 22);
        break;
    }

    final isMoMo = account.provider == 'mtn_momo';
    final textColor = isMoMo ? const Color(0xFF1F2937) : Colors.white;
    final textMutedColor = isMoMo ? const Color(0xFF4B5563) : Colors.white70;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(isMoMo ? 0.35 : 0.2),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  // Decorative cartoon sheen orb
                  Positioned(
                    top: -25,
                    right: -25,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(isMoMo ? 0.2 : 0.12),
                      ),
                    ),
                  ),

                  // Card Content
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Chip/Icon & Brand Label + Default Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                providerIconWidget,
                                const SizedBox(width: 10),
                                Text(
                                  providerLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            if (account.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(isMoMo ? 0.35 : 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: textColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Account Name & Masked Digits
                        Text(
                          account.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.maskedNumber,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            letterSpacing: 1.5,
                            color: textMutedColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Balance & Reconciled Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BALANCE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: textMutedColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(account.lastBalance),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(isMoMo ? 0.1 : 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    DateFormatter.formatShortDate(account.lastBalanceDate),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ],
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
        ),
      ),
    );
  }

  Widget _buildMiniChip(Color color) {
    return Container(
      width: 28,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF78350F).withOpacity(0.6),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: const Color(0xFF78350F).withOpacity(0.5),
              width: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}
