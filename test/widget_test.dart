import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/main.dart';

void main() {
  testWidgets('App starts and shows landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartHatchApp());

    expect(find.text('Smarter Hatching,\nBetter Results.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
