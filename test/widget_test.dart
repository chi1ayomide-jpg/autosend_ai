import 'package:flutter_test/flutter_test.dart';
import 'package:autosend_ai/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoSendApp());
    expect(find.byType(AutoSendApp), findsOneWidget);
  });
}
