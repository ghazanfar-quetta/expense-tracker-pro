import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../utils/app_settings.dart';

class ReportsPage extends StatefulWidget {
  final AppSettings appSettings;
  final List<Map<String, dynamic>> transactions;

  const ReportsPage({
    super.key,
    required this.appSettings,
    required this.transactions,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedReportType = 'Monthly Summary';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _useCustomDateRange = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Report Controls Section
          _buildReportControls(context),
          const SizedBox(height: 16),

          // Report Summary Cards
          _buildSummaryCards(context),
          const SizedBox(height: 16),

          // Report Content
          Expanded(
            child: _buildReportContent(context),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        appSettings: widget.appSettings,
        transactions: widget.transactions,
        currentPage: 'reports',
      ),
    );
  }

  Widget _buildReportControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Report Type Selection
          Row(
            children: [
              const Text('Report Type:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedReportType,
                  isExpanded: true,
                  items: [
                    'Monthly Summary',
                    'Category Breakdown',
                    'Income vs Expense',
                    'Custom Report'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedReportType = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Range Selection
          Row(
            children: [
              const Text('Date Range:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<bool>(
                  value: _useCustomDateRange,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem<bool>(
                      value: false,
                      child: Text('Last 30 Days'),
                    ),
                    DropdownMenuItem<bool>(
                      value: true,
                      child: Text('Custom Range'),
                    ),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _useCustomDateRange = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),

          // Custom Date Range Picker
          if (_useCustomDateRange) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('From:', style: TextStyle(fontSize: 12)),
                      GestureDetector(
                        onTap: () => _selectStartDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDate(_startDate)),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('To:', style: TextStyle(fontSize: 12)),
                      GestureDetector(
                        onTap: () => _selectEndDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDate(_endDate)),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Generate Report Button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 249, 145, 110),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Generate Report',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();
    final totalIncome = _calculateTotalIncome(filteredTransactions);
    final totalExpense = _calculateTotalExpense(filteredTransactions);
    final netAmount = totalIncome - totalExpense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Income Card
          Expanded(
            child: _buildSummaryCard(
              context,
              'Income',
              '${widget.appSettings.currencySymbol} ${totalIncome.toStringAsFixed(2)}',
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          // Expense Card
          Expanded(
            child: _buildSummaryCard(
              context,
              'Expense',
              '${widget.appSettings.currencySymbol} ${totalExpense.toStringAsFixed(2)}',
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          // Net Amount Card
          Expanded(
            child: _buildSummaryCard(
              context,
              'Net',
              '${widget.appSettings.currencySymbol} ${netAmount.toStringAsFixed(2)}',
              netAmount >= 0 ? Colors.blue : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a report to see analytics',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Transaction List
        Text(
          'Transactions (${filteredTransactions.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...filteredTransactions
            .map((transaction) => _buildTransactionItem(transaction)),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final bool isIncome = transaction['amount'] > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (transaction['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction['icon'] as IconData,
              color: transaction['color'] as Color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  transaction['category'] as String,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isIncome
                    ? '+${widget.appSettings.currencySymbol} ${transaction['amount'].toStringAsFixed(2)}'
                    : '-${widget.appSettings.currencySymbol} ${(transaction['amount'] as double).abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                transaction['date'] as String,
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Methods
  List<Map<String, dynamic>> _getFilteredTransactions() {
    DateTime startDate = _useCustomDateRange
        ? _startDate
        : DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = _useCustomDateRange ? _endDate : DateTime.now();

    return widget.transactions.where((transaction) {
      final transactionDate = _parseDate(transaction['date'] as String);
      return transactionDate
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          transactionDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  double _calculateTotalIncome(List<Map<String, dynamic>> transactions) {
    return transactions
        .where((t) => t['amount'] > 0)
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
  }

  double _calculateTotalExpense(List<Map<String, dynamic>> transactions) {
    return transactions
        .where((t) => t['amount'] < 0)
        .fold(0.0, (sum, t) => sum + (t['amount'] as double).abs());
  }

  DateTime _parseDate(String dateString) {
    if (dateString.toLowerCase() == 'today') {
      return DateTime.now();
    }

    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $dateString');
    }

    return DateTime(1900);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _generateReport() {
    setState(() {
      // This will trigger a rebuild with the new filtered data
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report generated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
