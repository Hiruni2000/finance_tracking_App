import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transactionController.dart';
import '../controllers/budgetController.dart';
import '../models/transactionModel.dart';
import '../controllers/authController.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final TransactionController _transactionController = TransactionController();
  final BudgetController _budgetController = BudgetController();

  bool _isLoading = true;
  List<TransactionModel> _recentTransactions = [];
  Map<String, dynamic> _budgetData = {
    'budget': 0.0,
    'spent': 0.0,
    'remaining': 0.0,
    'progress': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Load dashboard data
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get recent transactions
      final transactions = await _transactionController.getTransactions();
      // Take only the 5 most recent transactions
      final recentTransactions = transactions.take(5).toList();

      // Get budget progress
      final budgetData = await _budgetController.getBudgetProgress();

      setState(() {
        _recentTransactions = recentTransactions;
        _budgetData = budgetData;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Finance App',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Add Transaction'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/addTransaction');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Transaction History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/transactionHistory');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Budget Planner'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/budgetPlanner');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports & Insights'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/reports');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                // Sign out using AuthController
                await Provider.of<AuthController>(
                  context,
                  listen: false,
                ).signOut();
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Budget Overview Card
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Budget Overview",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: _budgetData['progress'],
                                minHeight: 10,
                                backgroundColor: Colors.grey[300],
                                color:Colors.red,

                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildBudgetItem(
                                    "Budget",
                                    "\$${_budgetData['budget'].toStringAsFixed(2)}",
                                    Colors.blue,
                                  ),
                                  _buildBudgetItem(
                                    "Spent",
                                    "\$${_budgetData['spent'].toStringAsFixed(2)}",
                                    Colors.red,
                                  ),
                                  _buildBudgetItem(
                                    "Remaining",
                                    "\$${_budgetData['remaining'].toStringAsFixed(2)}",
                                    Colors.green,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Recent Transactions
                      const Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _recentTransactions.isEmpty
                          ? const Card(
                            elevation: 2,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  "No transactions yet. Add your first transaction!",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _recentTransactions[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        transaction.type == 'Income'
                                            ? Colors.green
                                            : Colors.red,
                                    child: Icon(
                                      transaction.type == 'Income'
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(transaction.category),
                                  subtitle: Text(transaction.description),
                                  trailing: Text(
                                    "\$${transaction.amount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          transaction.type == 'Income'
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                      const SizedBox(height: 16),

                      // Quick Actions
                      const Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickActionButton(
                            "Add Expense",
                            Icons.remove_circle,
                            Colors.red,
                            () {
                              Navigator.pushNamed(
                                context,
                                '/addTransaction',
                                arguments: {'type': 'Expense'},
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            "Add Income",
                            Icons.add_circle,
                            Colors.green,
                            () {
                              Navigator.pushNamed(
                                context,
                                '/addTransaction',
                                arguments: {'type': 'Income'},
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            "Set Budget",
                            Icons.account_balance_wallet,
                            Colors.blue,
                            () {
                              Navigator.pushNamed(context, '/budgetPlanner');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildBudgetItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
