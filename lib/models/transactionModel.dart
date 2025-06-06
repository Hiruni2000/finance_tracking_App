class TransactionModel {
  final String id;
  final String type; // Income or Expense
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String userId;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.userId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
      'userId': userId,
    };
  }

  // Create from Firestore document
  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      id: docId,
      type: map['type'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      date: map['date']?.toDate() ?? DateTime.now(),
      userId: map['userId'] ?? '',
    );
  }
}