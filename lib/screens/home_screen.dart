import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await DatabaseHelper.instance.getExpenses();

      if (!mounted) return;

      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load expenses: $error'),
        ),
      );
    }
  }

  double get _totalExpenses {
    return _expenses.fold(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  double get _todayExpenses {
    final now = DateTime.now();

    return _expenses
        .where((expense) {
          final expenseDate = DateTime.parse(expense.date);

          return expenseDate.year == now.year &&
              expenseDate.month == now.month &&
              expenseDate.day == now.day;
        })
        .fold(
          0,
          (total, expense) => total + expense.amount,
        );
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);

    return '${parsedDate.day.toString().padLeft(2, '0')}/'
        '${parsedDate.month.toString().padLeft(2, '0')}/'
        '${parsedDate.year}';
  }

  Future<void> _openAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _loadExpenses,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _expenses.isEmpty
                ? _buildEmptyState()
                : _buildDashboard(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Expenses',
                amount: _totalExpenses,
                icon: Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Today',
                amount: _todayExpenses,
                icon: Icons.today,
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        Text(
          'Recent Expenses',
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 12),

        ..._expenses.map(_buildExpenseCard),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }


Future<void> _editExpense(Expense expense) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddExpenseScreen(
        expense: expense,
      ),
    ),
  );

  _loadExpenses();
}

Future<void> _deleteExpense(Expense expense) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Expense'),
        content: Text(
          'Are you sure you want to delete "${expense.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true) {
    return;
  }

  try {
    await DatabaseHelper.instance.deleteExpense(expense.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense deleted successfully!'),
      ),
    );

    _loadExpenses();
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to delete expense: $error'),
      ),
    );
  }
}

  Widget _buildExpenseCard(Expense expense) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: CircleAvatar(
        child: Icon(_getCategoryIcon(expense.category)),
      ),
      title: Text(
        expense.description,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${expense.category} • ${_formatDate(expense.date)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '₹${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _editExpense(expense),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => _deleteExpense(expense),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
          ),
        ],
      ),
    ),
  );
}

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Travel':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.health_and_safety;
      case 'Education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.receipt_long_outlined,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tap "Add Expense" to record your first expense.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}