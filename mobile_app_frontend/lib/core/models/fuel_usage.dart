class FuelUsage {
  final DateTime date;
  final double amount; // Fuel amount in liters

  FuelUsage({required this.date, required this.amount});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
      };

  factory FuelUsage.fromJson(Map<String, dynamic> json) => FuelUsage(
        date: DateTime.parse(json['date']),
        amount: json['amount'],
      );
}
