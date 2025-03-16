class Expense {
  String id;
  String title;
  double amount;
  DateTime date;

  Expense({required this.id, required this.title, required this.amount, required this.date});

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "amount": amount,
        "date": date.toIso8601String(),
      };

  static Expense fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        title: json['title'],
        amount: json['amount'],
        date: DateTime.parse(json['date']),
      );
}
