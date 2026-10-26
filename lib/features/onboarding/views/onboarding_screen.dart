import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../shell/app_shell.dart';
import '../data/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _slides = const [
    _OnboardingItem(
      title: 'Automatic Alert Tracking',
      subtitle:
          'Kudi Lens reads official bank & MoMo debit alerts in real-time across GCB, Ecobank, CalBank, Stanbic, Absa, Fidelity, MTN MoMo, and Telecel Cash.',
      tag: 'NO MANUAL LOGGING REQUIRED',
      icon: Icons.notifications_active_rounded,
      illustrationType: _IllustrationType.alerts,
    ),
    _OnboardingItem(
      title: '100% Offline & Private',
      subtitle:
          'No bank passwords, no cloud servers, and zero data tracking. Your financial records are encrypted with AES-256 and stored exclusively on your device.',
      tag: 'ZERO CLOUD FOOTPRINT',
      icon: Icons.shield_rounded,
      illustrationType: _IllustrationType.security,
    ),
    _OnboardingItem(
      title: 'Smart Card OCR & Fees',
      subtitle:
          'Capture physical cards with instant camera OCR, separate hidden bank levies and SMS fees, and link multi-hop wallet transfers without double-counting.',
      tag: 'TOTAL FINANCIAL CLARITY',
      icon: Icons.document_scanner_rounded,
      illustrationType: _IllustrationType.scanner,
    ),
  ];

  void _finishOnboarding() async {
    await OnboardingService.completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const AppShell(),
        ),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              'Skip',
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Page Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Slide Visual Hero Card
                        _buildSlideVisual(slide, palette),
                        const SizedBox(height: 36),

                        // Pill Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withOpacity(palette.isDark ? 0.2 : 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            slide.tag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation & Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                children: [
                  // Smooth Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (idx) {
                      final isActive = idx == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : palette.border.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Primary CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastPage ? 'Get Started' : 'Continue',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLastPage
                                ? Icons.arrow_forward_rounded
                                : Icons.chevron_right_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideVisual(_OnboardingItem slide, AppPalette palette) {
    switch (slide.illustrationType) {
      case _IllustrationType.alerts:
        return _buildAlertsVisual(palette);
      case _IllustrationType.security:
        return _buildSecurityVisual(palette);
      case _IllustrationType.scanner:
        return _buildScannerVisual(palette);
    }
  }

  // Visual 1: Cartoon Alert Stack
  Widget _buildAlertsVisual(AppPalette palette) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? 0.3 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, size: 15, color: palette.textPrimary),
                  const SizedBox(width: 4),
                  Text(
                    'GCB Bank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.expense.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DEBIT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.expense,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '- GHS 240.00',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'POS CHOP BAR OSU • ACCRA',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildMiniTag('Food & Dining', Icons.restaurant_rounded, palette),
              _buildMiniTag('1-Tap Tag', Icons.check_circle_outline_rounded, palette),
            ],
          ),
        ],
      ),
    );
  }

  // Visual 2: Offline Encrypted Vault
  Widget _buildSecurityVisual(AppPalette palette) {
    return Container(
      width: 240,
      height: 200,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(palette.isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.35),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Color(0xFF10B981),
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'AES-256 ENCRYPTED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Local Database Only',
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
      ),
    );
  }

  // Visual 3: Camera OCR & Cartoon Card
  Widget _buildScannerVisual(AppPalette palette) {
    return Container(
      width: 280,
      height: 170,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0C4A6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ECOBANK GHANA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'OCR READY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Text(
            '5399 •••• •••• 3319',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 15,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'AMA SERWAA',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '11/27',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTag(String label, IconData icon, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: palette.textPrimary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

enum _IllustrationType { alerts, security, scanner }

class _OnboardingItem {
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final _IllustrationType illustrationType;

  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.illustrationType,
  });
}
