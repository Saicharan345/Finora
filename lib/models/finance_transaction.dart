class FinanceTransaction {
  const FinanceTransaction({required this.id, required this.amount, required this.isIncome, required this.category, required this.title, required this.date, this.note = ''});

  final String id;
  final double amount;
  final bool isIncome;
  final String category;
  final String title;
  final DateTime date;
  final String note;

  Map<String, Object?> toJson() => {'id': id, 'amount': amount, 'isIncome': isIncome, 'category': category, 'title': title, 'date': date.toIso8601String(), 'note': note};

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) => FinanceTransaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        isIncome: json['isIncome'] as bool,
        category: json['category'] as String,
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String? ?? '',
      );
}
