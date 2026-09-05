class Expense {
  final int? id;
  final double amount;
  final String category;
  final String description;
  final String date;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  // Convert Expense object into a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
    };
  }

  // Convert SQLite Map into an Expense object
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      description: map['description'] as String,
      date: map['date'] as String,
    );
  }
}