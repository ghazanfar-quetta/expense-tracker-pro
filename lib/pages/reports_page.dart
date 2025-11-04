import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  // Professional date range options
  final List<String> _dateRangeOptions = [
    'Today',
    'Yesterday',
    'Last 7 Days',
    'Last 30 Days',
    'This Month',
    'Last Month',
    'This Year',
    'Custom Range',
  ];

  // Professional report types
  final List<String> _reportTypes = [
    'Summary',
    'Category Breakdown',
    'Income vs Expense',
    'Trend Analysis',
  ];

  @override
  void initState() {
    super.initState();
    widget.appSettings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    widget.appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {}); // Rebuild when report settings change
  }

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
          _buildFilterRow(
            'Report Type',
            widget.appSettings.reportType,
            _reportTypes,
            (newValue) {
              widget.appSettings.setReportType(newValue!);
            },
          ),
          const SizedBox(height: 16),

          // Date Range Selection
          _buildFilterRow(
            'Date Range',
            widget.appSettings.reportDateRange,
            _dateRangeOptions,
            (newValue) {
              widget.appSettings.updateReportDateRange(newValue!);
              widget.appSettings
                  .setReportShowCustomDatePicker(newValue == 'Custom Range');
            },
          ),

          // Custom Date Range Picker
          if (widget.appSettings.reportShowCustomDatePicker) ...[
            const SizedBox(height: 16),
            _buildCustomDateRange(),
          ],

          // Generate Report Button
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _generateReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 249, 145, 110),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Generate Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 60,
                child: ElevatedButton(
                  onPressed: _exportReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(
    String label,
    String selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDateRange() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Custom Date Range',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'Start Date',
                  widget.appSettings.reportStartDate,
                  () => _selectStartDate(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  'End Date',
                  widget.appSettings.reportEndDate,
                  () => _selectEndDate(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(date),
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
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
              Icons.arrow_upward,
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
              Icons.arrow_downward,
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
              netAmount >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
              'Try adjusting your filters or date range',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Report Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.appSettings.reportType} Report',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getDateRangeLabel(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Chip(
                backgroundColor:
                    const Color.fromARGB(255, 249, 145, 110).withOpacity(0.1),
                label: Text(
                  '${filteredTransactions.length} transactions',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 249, 145, 110),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Transaction List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...filteredTransactions
                  .map((transaction) => _buildTransactionItem(transaction)),
            ],
          ),
        ),
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
        border: Border.all(color: Colors.grey.shade100),
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
                const SizedBox(height: 2),
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
              const SizedBox(height: 2),
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

  // Export Report Method
  Future<void> _exportReport() async {
    try {
      final filteredTransactions = _getFilteredTransactions();

      if (filteredTransactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No transactions to export!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final totalIncome = _calculateTotalIncome(filteredTransactions);
      final totalExpense = _calculateTotalExpense(filteredTransactions);
      final netAmount = totalIncome - totalExpense;

      // Create report content
      String reportContent = '''
EXPENSE TRACKER PRO - REPORT
Generated on: ${_formatDate(DateTime.now())}
Report Type: ${widget.appSettings.reportType}
Date Range: ${_getDateRangeLabel()}

SUMMARY:
• Total Income: ${widget.appSettings.currencySymbol} ${totalIncome.toStringAsFixed(2)}
• Total Expense: ${widget.appSettings.currencySymbol} ${totalExpense.toStringAsFixed(2)}
• Net Amount: ${widget.appSettings.currencySymbol} ${netAmount.toStringAsFixed(2)}
• Transactions Count: ${filteredTransactions.length}

TRANSACTION DETAILS:
${_formatTransactionsForExport(filteredTransactions)}
''';

      // Get directory for saving file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Expense_Report_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');

      // Write to file
      await file.writeAsString(reportContent);

      // Share the file
      await Share.shareXFiles([XFile(file.path)],
          subject: 'Expense Tracker Pro Report',
          text:
              'Here is your ${widget.appSettings.reportType} report for ${widget.appSettings.reportDateRange}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to format transactions for export
  String _formatTransactionsForExport(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) return 'No transactions found.';

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      final isIncome = transaction['amount'] > 0;
      final amount = isIncome
          ? '+${widget.appSettings.currencySymbol} ${transaction['amount'].toStringAsFixed(2)}'
          : '-${widget.appSettings.currencySymbol} ${(transaction['amount'] as double).abs().toStringAsFixed(2)}';

      buffer.writeln('${i + 1}. ${transaction['title']}');
      buffer.writeln('   Category: ${transaction['category']}');
      buffer.writeln('   Amount: $amount');
      buffer.writeln('   Date: ${transaction['date']}');
      buffer.writeln('   Type: ${isIncome ? 'Income' : 'Expense'}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  // Helper Methods
  String _getDateRangeLabel() {
    if (widget.appSettings.reportDateRange == 'Custom Range') {
      return '${_formatDate(widget.appSettings.reportStartDate)} - ${_formatDate(widget.appSettings.reportEndDate)}';
    }
    return widget.appSettings.reportDateRange;
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    return widget.transactions.where((transaction) {
      final transactionDate = _parseDate(transaction['date'] as String);
      return transactionDate.isAfter(widget.appSettings.reportStartDate
              .subtract(const Duration(days: 1))) &&
          transactionDate.isBefore(
              widget.appSettings.reportEndDate.add(const Duration(days: 1)));
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
      initialDate: widget.appSettings.reportStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != widget.appSettings.reportStartDate) {
      widget.appSettings
          .setReportDates(picked, widget.appSettings.reportEndDate);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.appSettings.reportEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != widget.appSettings.reportEndDate) {
      widget.appSettings
          .setReportDates(widget.appSettings.reportStartDate, picked);
    }
  }

  void _generateReport() {
    setState(() {
      // This will trigger a rebuild with the new filtered data
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${widget.appSettings.reportType} report generated for ${widget.appSettings.reportDateRange}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
