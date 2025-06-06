import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transactionModel.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore.collection('transactions').add(transaction.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get all transactions for a user
  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('transactions')
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get total spent amount for a user
  Future<double> getTotalSpent(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('transactions')
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'Expense')
              .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += doc.data()['amount']?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      rethrow;
    }
  }
}
