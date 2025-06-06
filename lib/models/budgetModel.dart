class BudgetModel {
  final double amount;
  final String month;
  final String year;
  final String userId;

  BudgetModel({
    required this.amount,
    required this.month,
    required this.year,
    required this.userId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'month': month,
      'year': year,
      'userId': userId,
    };
  }

  // Create from Firestore document
  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      amount: map['amount']?.toDouble() ?? 0.0,
      month: map['month'] ?? '',
      year: map['year'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}