import 'package:flutter/material.dart';
import '../controllers/transactionController.dart';
import '../models/transactionModel.dart';

class ReportsInsightsView extends StatefulWidget {
  const ReportsInsightsView({super.key});

  @override
  State<ReportsInsightsView> createState() => _ReportsInsightsViewState();
}

class _ReportsInsightsViewState extends State<ReportsInsightsView> {
  final TransactionController _transactionController = TransactionController();

  bool _isLoading = true;
  List<TransactionModel> _allTransactions = [];

  // Summary data
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _netSavings = 0;

  // Category data
  Map<String, double> _expenseByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  // Load transaction data
  Future<void> _loadTransactionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _transactionController.getTransactions();

      // Calculate summary data
      double totalIncome = 0;
      double totalExpense = 0;
      Map<String, double> expenseByCategory = {};

      for (var transaction in transactions) {
        if (transaction.type == 'Income') {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;

          // Add to category data
          if (expenseByCategory.containsKey(transaction.category)) {
            expenseByCategory[transaction.category] =
                expenseByCategory[transaction.category]! + transaction.amount;
          } else {
            expenseByCategory[transaction.category] = transaction.amount;
          }
        }
      }

      setState(() {
        _allTransactions = transactions;
        _totalIncome = totalIncome;
        _totalExpense = totalExpense;
        _netSavings = totalIncome - totalExpense;
        _expenseByCategory = expenseByCategory;
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

  // Calculate total percentage
  double _calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports & Insights"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactionData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadTransactionData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Financial Summary Card
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Financial Summary",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSummaryItem(
                                    "Income",
                                    _totalIncome,
                                    Colors.green,
                                  ),
                                  _buildSummaryItem(
                                    "Expenses",
                                    _totalExpense,
                                    Colors.red,
                                  ),
                                  _buildSummaryItem(
                                    "Savings",
                                    _netSavings,
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Expense by Category
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Expense by Category",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _expenseByCategory.isEmpty
                                  ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        "No expense data available",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                  : Column(
                                    children:
                                        _expenseByCategory.entries.map((entry) {
                                          final percentage =
                                              _calculatePercentage(
                                                entry.value,
                                                _totalExpense,
                                              );

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      entry.key,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      "\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                LinearProgressIndicator(
                                                  value: percentage / 100,
                                                  minHeight: 8,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        _getCategoryColor(
                                                          entry.key,
                                                        ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Insights Card
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Financial Insights",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInsightItem(
                                "Savings Rate",
                                _totalIncome > 0
                                    ? "You're saving ${(_netSavings / _totalIncome * 100).toStringAsFixed(1)}% of your income"
                                    : "Add income to calculate your savings rate",
                                _netSavings >= 0
                                    ? Icons.thumb_up
                                    : Icons.thumb_down,
                                _netSavings >= 0 ? Colors.green : Colors.red,
                              ),
                              const Divider(),
                              _buildInsightItem(
                                "Top Expense",
                                _getTopExpenseCategory(),
                                Icons.category,
                                Colors.orange,
                              ),
                              const Divider(),
                              _buildInsightItem(
                                "Monthly Trend",
                                _getMonthlySavingsTrend(),
                                Icons.trending_up,
                                Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(message, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }

  // Get top expense category
  String _getTopExpenseCategory() {
    if (_expenseByCategory.isEmpty) {
      return "No expense data available";
    }

    var topCategory = _expenseByCategory.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return "Your highest spending is in ${topCategory.key} (\$${topCategory.value.toStringAsFixed(2)})";
  }

  // Get monthly savings trend
  String _getMonthlySavingsTrend() {
    if (_allTransactions.isEmpty) {
      return "Add transactions to see monthly trends";
    }

    if (_netSavings > 0) {
      return "You're saving money this month! Keep it up!";
    } else if (_netSavings < 0) {
      return "You're spending more than you earn this month";
    } else {
      return "You're breaking even this month";
    }
  }

  // Get color for category
  Color _getCategoryColor(String category) {
    // Simple hash function to generate consistent colors for categories
    int hash = category.hashCode;
    return Color.fromRGBO(
      (hash & 0xFF),
      ((hash >> 8) & 0xFF),
      ((hash >> 16) & 0xFF),
      1,
    );
  }
}
