// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

void main() {
  testWidgets('Task Manager app smoke test', (WidgetTester tester) async {
    // بناء التطبيق
    await tester.pumpWidget(const TaskManagerApp());
    await tester.pumpAndSettle();

    // التحقق من وجود عنوان التطبيق
    expect(find.text('مدير المهام'), findsOneWidget);
  });
}
