import 'package:flutter_test/flutter_test.dart';

import 'package:progree_task_2_expense_tracker/main.dart';

void main() {
  testWidgets('Expense Tracker app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    expect(find.text('Add Expense'), findsOneWidget);
    expect(find.text('Save Expense'), findsOneWidget);
  });
}