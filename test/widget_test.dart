import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kudi_lens/main.dart';

void main() {
  testWidgets('KudiLensApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KudiLensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kudi Lens'), findsOneWidget);
    expect(find.text('Pocket Spend Tracker'), findsOneWidget);
  });
}
