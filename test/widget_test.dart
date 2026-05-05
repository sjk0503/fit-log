import 'package:flutter_test/flutter_test.dart';

import 'package:fit_log/main.dart';

void main() {
  testWidgets('App should start with HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const FitLogApp());

    expect(find.text('Fit-Log'), findsOneWidget);
  });
}
