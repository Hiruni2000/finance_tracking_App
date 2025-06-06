import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budgetModel.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Set budget for a month
  Future<void> setBudget(BudgetModel budget) async {
    try {
      // First check if budget exists for this month and year
      final snapshot =
          await _firestore
              .collection('budgets')
              .where('userId', isEqualTo: budget.userId)
              .where('month', isEqualTo: budget.month)
              .where('year', isEqualTo: budget.year)
              .get();

      if (snapshot.docs.isNotEmpty) {
        // Update existing budget
        await _firestore
            .collection('budgets')
            .doc(snapshot.docs.first.id)
            .update(budget.toMap());
      } else {
        // Create new budget
        await _firestore.collection('budgets').add(budget.toMap());
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get budget for a specific month
  Future<BudgetModel?> getBudget(
    String userId,
    String month,
    String year,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('budgets')
              .where('userId', isEqualTo: userId)
              .where('month', isEqualTo: month)
              .where('year', isEqualTo: year)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return BudgetModel.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
