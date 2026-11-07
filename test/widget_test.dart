import 'package:flutter_test/flutter_test.dart';
import 'package:lab2_app/main.dart';

void main() {
  testWidgets('App renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Users & Posts Feed'), findsOneWidget);
  });
}
