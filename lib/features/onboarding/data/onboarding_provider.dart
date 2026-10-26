import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kHasCompletedOnboardingKey = 'has_completed_onboarding';

class OnboardingService {
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kHasCompletedOnboardingKey) ?? false;
  }

  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasCompletedOnboardingKey, true);
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasCompletedOnboardingKey, false);
  }
}

final onboardingStatusProvider = FutureProvider<bool>((ref) async {
  return OnboardingService.hasCompletedOnboarding();
});
