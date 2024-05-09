class Expense {
  final String category;
  final double amount;
  final DateTime date;

  Expense({required this.category, required this.amount, required this.date});

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      category: map['category'] as String,
      amount: (map['price'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }
}
