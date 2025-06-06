import '../models/budgetModel.dart';
import '../services/budgetService.dart';
import '../services/authService.dart';
import '../services/transactionService.dart';

class BudgetController {
  final BudgetService _budgetService = BudgetService();
  final AuthService _authService = AuthService();
  final TransactionService _transactionService = TransactionService();

  // Set budget for current month
  Future<void> setBudget(double amount) async {
    try {
      // Get current user
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw "User not authenticated";
      }

      // Get current month and year
      final now = DateTime.now();
      final month = now.month.toString();
      final year = now.year.toString();

      // Create budget model
      final budget = BudgetModel(
        amount: amount,
        month: month,
        year: year,
        userId: user.id,
      );

      // Set budget
      await _budgetService.setBudget(budget);
    } catch (e) {
      throw "Failed to set budget: $e";
    }
  }

  // Get current month's budget
  Future<BudgetModel?> getCurrentBudget() async {
    try {
      // Get current user
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw "User not authenticated";
      }

      // Get current month and year
      final now = DateTime.now();
      final month = now.month.toString();
      final year = now.year.toString();

      // Get budget from service
      return await _budgetService.getBudget(user.id, month, year);
    } catch (e) {
      throw "Failed to get budget: $e";
    }
  }

  // Calculate budget progress
  Future<Map<String, dynamic>> getBudgetProgress() async {
    try {
      // Get current user
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw "User not authenticated";
      }

      // Get current budget
      final budget = await getCurrentBudget();

      // Get total spent
      final spent = await _transactionService.getTotalSpent(user.id);

      // Calculate remaining and progress
      final budgetAmount = budget?.amount ?? 0;
      final remaining = budgetAmount - spent;
      final progress =
          budgetAmount > 0 ? (spent / budgetAmount).clamp(0.0, 1.0) : 0.0;

      return {
        'budget': budgetAmount,
        'spent': spent,
        'remaining': remaining,
        'progress': progress,
      };
    } catch (e) {
      throw "Failed to calculate budget progress: $e";
    }
  }
}
