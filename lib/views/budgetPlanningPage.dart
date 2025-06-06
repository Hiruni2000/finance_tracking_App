import 'package:flutter/material.dart';
import '../controllers/budgetController.dart';

class BudgetPlanningView extends StatefulWidget {
  const BudgetPlanningView({super.key});

  @override
  State<BudgetPlanningView> createState() => _BudgetPlanningViewState();
}

class _BudgetPlanningViewState extends State<BudgetPlanningView> {
  final BudgetController _budgetController = BudgetController();

  final _budgetAmountController = TextEditingController();

  bool _isLoading = true;
  Map<String, dynamic> _budgetData = {
    'budget': 0.0,
    'spent': 0.0,
    'remaining': 0.0,
    'progress': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  // Load budget data
  Future<void> _loadBudgetData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final budgetData = await _budgetController.getBudgetProgress();
      setState(() {
        _budgetData = budgetData;
        // Set the budget controller to current budget amount
        _budgetAmountController.text = budgetData['budget'].toString();
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Set budget
  Future<void> _setBudget() async {
    // Validate amount
    if (_budgetAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a budget amount")),
      );
      return;
    }

    final amount = double.tryParse(_budgetAmountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _budgetController.setBudget(amount);

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Budget set successfully")));

      // Reload budget data
      _loadBudgetData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Budget Planner")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Budget Status
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Current Monthly Budget",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Budget Amount",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      "\$${_budgetData['budget'].toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Current Month",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: _budgetData['progress'],
                              minHeight: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _budgetData['progress'] > 0.8
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Spent",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      "\$${_budgetData['spent'].toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "Remaining",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      "\$${_budgetData['remaining'].toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Set New Budget
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Set New Budget",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _budgetAmountController,
                              decoration: const InputDecoration(
                                labelText: "Budget Amount",
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                                hintText: "Enter your monthly budget",
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _setBudget,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Set Budget"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Budget Tips
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Budget Tips",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTipItem(
                              "50/30/20 Rule",
                              "Allocate 50% of your budget to needs, 30% to wants, and 20% to savings.",
                              Icons.pie_chart,
                            ),
                            const Divider(),
                            _buildTipItem(
                              "Track Everything",
                              "Record all expenses, no matter how small, to understand your spending habits.",
                              Icons.track_changes,
                            ),
                            const Divider(),
                            _buildTipItem(
                              "Review Regularly",
                              "Review your budget weekly to stay on track with your financial goals.",
                              Icons.repeat,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTipItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }
}
