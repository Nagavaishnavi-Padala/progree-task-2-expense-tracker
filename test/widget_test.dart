import 'package:flutter_test/flutter_test.dart';

import 'package:progree_task_2_expense_tracker/main.dart';

void main() {
  testWidgets('Expense Tracker app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
  });
}

