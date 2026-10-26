import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kudi_lens/main.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Fresh install shows splash and navigates to Onboarding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'has_completed_onboarding': false});

    await tester.pumpWidget(
      const ProviderScope(
        child: KudiLensApp(),
      ),
    );

    // Initial splash state
    expect(find.text('Kudi Lens'), findsOneWidget);

    // Settle splash delay and animation
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    // Verify Onboarding screen content
    expect(find.text('Automatic Alert Tracking'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Completed onboarding navigates directly to Home Shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'has_completed_onboarding': true});

    await tester.pumpWidget(
      const ProviderScope(
        child: KudiLensApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    expect(find.text('Kudi Lens'), findsOneWidget);
    expect(find.text('Pocket Spend Tracker'), findsOneWidget);
  });
}

