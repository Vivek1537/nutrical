import 'package:flutter_test/flutter_test.dart';
import 'package:nutrical/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const NutriCalApp());
    await tester.pumpAndSettle();
  });
}
