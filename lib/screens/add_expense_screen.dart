import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({
    super.key,
    this.expense,
  });

  final Expense? expense;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    if (expense != null) {
      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description;
      _selectedCategory = expense.category;
      _selectedDate = DateTime.parse(expense.date);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final expense = Expense(
      id: widget.expense?.id,
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory!,
      description: _descriptionController.text.trim(),
      date: _selectedDate.toIso8601String(),
    );

    debugPrint('SAVE: Button pressed');

    try {
      if (widget.expense == null) {
        // CREATE
        debugPrint('SAVE: Creating new expense');

        await DatabaseHelper.instance.createExpense(expense);

        debugPrint('SAVE: Expense created successfully');
      } else {
        // UPDATE
        debugPrint('SAVE: Updating expense ID ${expense.id}');

        await DatabaseHelper.instance.updateExpense(expense);

        debugPrint('SAVE: Expense updated successfully');
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error, stackTrace) {
      debugPrint('SAVE ERROR: $error');
      debugPrint('SAVE STACK TRACE: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save expense: $error'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Expense' : 'Add Expense',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Edit your expense' : 'Add a new expense',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What was this expense for?',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate.year}',
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                FilledButton.icon(
                  onPressed: _saveExpense,
                  icon: Icon(
                    isEditing ? Icons.update : Icons.save,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    child: Text(
                      isEditing ? 'Update Expense' : 'Save Expense',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}