import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/transactionController.dart';
import '../models/transactionModel.dart';

class TransactionHistoryView extends StatefulWidget {
  const TransactionHistoryView({super.key});

  @override
  State<TransactionHistoryView> createState() => _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<TransactionHistoryView> {
  final TransactionController _transactionController = TransactionController();

  bool _isLoading = true;
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];

  // Filter options
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Income', 'Expense'];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Load transactions
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _transactionController.getTransactions();
      setState(() {
        _allTransactions = transactions;
        _filteredTransactions = transactions;
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

  // Apply filter
  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;

      if (filter == 'All') {
        _filteredTransactions = _allTransactions;
      } else {
        _filteredTransactions =
            _allTransactions
                .where((transaction) => transaction.type == filter)
                .toList();
      }
    });
  }

  // Format date
  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Filter Chips
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      children:
                          _filterOptions.map((filter) {
                            return FilterChip(
                              label: Text(filter),
                              selected: _selectedFilter == filter,
                              onSelected: (selected) {
                                if (selected) {
                                  _applyFilter(filter);
                                }
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor:
                                  filter == 'Income'
                                      ? Colors.green.withOpacity(0.2)
                                      : filter == 'Expense'
                                      ? Colors.red.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.2),
                              checkmarkColor:
                                  filter == 'Income'
                                      ? Colors.green
                                      : filter == 'Expense'
                                      ? Colors.red
                                      : Colors.blue,
                              labelStyle: TextStyle(
                                color:
                                    _selectedFilter == filter
                                        ? filter == 'Income'
                                            ? Colors.green
                                            : filter == 'Expense'
                                            ? Colors.red
                                            : Colors.blue
                                        : Colors.black,
                                fontWeight:
                                    _selectedFilter == filter
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  // Transaction List
                  Expanded(
                    child:
                        _filteredTransactions.isEmpty
                            ? Center(
                              child: Text(
                                "No $_selectedFilter transactions found",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: _filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final transaction =
                                    _filteredTransactions[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
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
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(transaction.category),
                                        Text(
                                          "\$${transaction.amount.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                transaction.type == 'Income'
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(transaction.description),
                                        Text(
                                          _formatDate(transaction.date),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTransaction').then((_) {
            _loadTransactions();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
