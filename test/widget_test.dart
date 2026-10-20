import 'package:flutter_test/flutter_test.dart';
import 'package:dhuanrader/main.dart';

void main() {
  testWidgets('DhuanRadar App initial render test', (WidgetTester tester) async {
    // Build DhuanRadarApp and trigger a frame.
    await tester.pumpWidget(const DhuanRadarApp());

    // Verify app bar title
    expect(find.text('DhuanRadar'), findsOneWidget);
    expect(find.text('ASHA / ANM'), findsOneWidget);
  });
}
