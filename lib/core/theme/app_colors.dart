import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Backgrounds & Surfaces
  static const Color bgDark = Color(0xFF0F172A); // Rich Obsidian Navy
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardBorderDark = Color(0xFF334155);

  // Light Theme Backgrounds & Surfaces (Playful, tactile, creamy modern fintech)
  static const Color bgLight = Color(0xFFF1F5F9); // Warm, clean canvas
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0);

  // Primary Cartoon Brand Colors
  static const Color primary = Color(0xFF3B82F6); // Electric Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);

  // Financial Personality Accents (Vibrant & Playful)
  static const Color income = Color(0xFF10B981); // Bubbly Emerald
  static const Color incomeDark = Color(0xFF059669);
  static const Color expense = Color(0xFFF43F5E); // Juicy Rose Coral
  static const Color expenseDark = Color(0xFFE11D48);
  static const Color fee = Color(0xFF8B5CF6); // Magic Violet
  static const Color feeDark = Color(0xFF7C3AED);
  static const Color transfer = Color(0xFF0EA5E9); // Vivid Sky Blue
  static const Color transferDark = Color(0xFF0284C7);
  static const Color pending = Color(0xFFF59E0B); // Amber Glow
  static const Color pendingDark = Color(0xFFD97706);
  static const Color cash = Color(0xFF0D9488); // Fresh Mint

  // Text Colors (Dark Theme)
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Text Colors (Light Theme)
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Provider Brand Accents
  static const Color calBankBlue = Color(0xFF1D4ED8);
  static const Color gcbGold = Color(0xFFD97706);
  static const Color ecobankTeal = Color(0xFF0284C7);
  static const Color stanbicBlue = Color(0xFF2563EB);
  static const Color absaRed = Color(0xFFBE123C);
  static const Color fidelityOrange = Color(0xFFEA580C);
  static const Color zenithRed = Color(0xFFDC2626);
  static const Color stanchartGreen = Color(0xFF059669);
  static const Color momoYellow = Color(0xFFFFC000);
  static const Color telecelRed = Color(0xFFEF4444);
  static const Color atMoneyBlue = Color(0xFF1E3A8A);
  static const Color cashGreen = Color(0xFF10B981);
}

class AppPalette {
  final BuildContext context;
  const AppPalette(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get bg => isDark ? AppColors.bgDark : AppColors.bgLight;
  Color get surface => isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get card => isDark ? AppColors.cardDark : AppColors.cardLight;
  Color get border => isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;

  Color get textPrimary => isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary => isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textMuted => isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

  // 3D Cartoon Shadow Generators
  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFF64748B).withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.15) : const Color(0xFF64748B).withOpacity(0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  List<BoxShadow> coloredShadow(Color color, {double opacity = 0.28, double blur = 14, double dy = 6}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        offset: Offset(0, dy),
        spreadRadius: -2,
      ),
    ];
  }
}

extension AppPaletteExtension on BuildContext {
  AppPalette get palette => AppPalette(this);
}
