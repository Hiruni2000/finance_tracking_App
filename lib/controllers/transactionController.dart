import '../models/transactionModel.dart';
import '../services/transactionService.dart';
import '../services/authService.dart';

class TransactionController {
  final TransactionService _transactionService = TransactionService();
  final AuthService _authService = AuthService();

  // Add a new transaction
  Future<void> addTransaction({
    required String type,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    try {
      // Get current user
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw "User not authenticated";
      }

      // Create transaction model
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        amount: amount,
        category: category,
        description: description,
        date: date,
        userId: user.id,
      );

      // Add to database
      await _transactionService.addTransaction(transaction);
    } catch (e) {
      throw "Failed to add transaction: $e";
    }
  }

  // Get all transactions for current user
  Future<List<TransactionModel>> getTransactions() async {
    try {
      // Get current user
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw "User not authenticated";
      }

      // Get transactions from service
      return await _transactionService.getTransactions(user.id);
    } catch (e) {
      throw "Failed to load transactions: $e";
    }
  }

  // Get total spent amount
  Future<double> getTotalSpent() async {
    try {
      // Get current user
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw "User not authenticated";
      }

      // Get total spent from service
      return await _transactionService.getTotalSpent(user.id);
    } catch (e) {
      throw "Failed to calculate total spent: $e";
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
