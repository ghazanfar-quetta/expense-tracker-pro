import 'package:flutter/material.dart';
import '../utils/app_settings.dart';
import '../widgets/custom_bottom_nav_bar.dart'; // ← ADD THIS IMPORT

class StatsPage extends StatefulWidget {
  final AppSettings appSettings;
  final List<Map<String, dynamic>> transactions;

  const StatsPage({
    super.key,
    required this.appSettings,
    required this.transactions,
  });

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedPeriod = 'Monthly';

  // Listen to settings changes
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
    setState(() {}); // Rebuild when settings change
  }

  // Format currency with current symbol
  String _formatCurrency(double amount) {
    return '${widget.appSettings.currencySymbol} ${amount.abs().toStringAsFixed(2)}';
  }

  // Calculate totals from actual transactions
  double get _totalIncome {
    return widget.transactions
        .where((transaction) => transaction['amount'] > 0)
        .fold(0, (sum, transaction) => sum + (transaction['amount'] as double));
  }

  double get _totalExpenses {
    return widget.transactions
        .where((transaction) => transaction['amount'] < 0)
        .fold(0, (sum, transaction) => sum + (transaction['amount'] as double));
  }

  double get _netSavings {
    return _totalIncome + _totalExpenses; // Expenses are negative
  }

  // Calculate category breakdown from actual transactions
  List<Map<String, dynamic>> get _categoryBreakdown {
    final Map<String, double> categorySums = {};
    final Map<String, Color> categoryColors = {};
    final Map<String, IconData> categoryIcons = {};

    // Process only expense transactions for category breakdown
    final expenses = widget.transactions.where((t) => t['amount'] < 0);

    for (final transaction in expenses) {
      final category = transaction['category'] as String;
      final amount = transaction['amount'] as double;
      final color = transaction['color'] as Color;
      final icon = transaction['icon'] as IconData;

      categorySums[category] = (categorySums[category] ?? 0) + amount.abs();
      categoryColors[category] = color;
      categoryIcons[category] = icon;
    }

    // Convert to list and calculate percentages
    final totalExpenses = _totalExpenses.abs();
    final List<Map<String, dynamic>> result = [];

    categorySums.forEach((category, amount) {
      final percentage =
          totalExpenses > 0 ? (amount / totalExpenses * 100).round() : 0;
      result.add({
        'name': category,
        'amount': amount,
        'color': categoryColors[category]!,
        'icon': categoryIcons[category]!,
        'percentage': percentage,
      });
    });

    // Sort by amount (descending)
    result.sort(
      (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
    );

    return result;
  }

  // Calculate top spending categories
  List<Map<String, dynamic>> get _topSpendingCategories {
    final breakdown = _categoryBreakdown;
    return breakdown.take(3).toList(); // Top 3 categories
  }

  @override
  Widget build(BuildContext context) {
    final hasTransactions = widget.transactions.isNotEmpty;
    final categoryBreakdown = _categoryBreakdown;
    final totalExpenses = _totalExpenses.abs();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor, // ← ADD THIS
        foregroundColor:
            Theme.of(context).appBarTheme.foregroundColor, // ← ADD THIS
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(),
            const SizedBox(height: 24),

            // Summary Cards
            _buildSummaryCards(),
            const SizedBox(height: 24),

            // Category Breakdown
            _buildCategoryBreakdown(
              hasTransactions,
              categoryBreakdown,
              totalExpenses,
            ),
            const SizedBox(height: 24),

            // Spending Insights
            if (hasTransactions) _buildSpendingInsights(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        // ← ADD THIS
        appSettings: widget.appSettings,
        transactions: widget.transactions,
        currentPage: 'stats',
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Weekly', 'Monthly', 'Yearly'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final hasTransactions = widget.transactions.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Income',
            _formatCurrency(_totalIncome),
            Icons.arrow_upward,
            Colors.green,
            hasTransactions,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Expenses',
            _formatCurrency(_totalExpenses.abs()),
            Icons.arrow_downward,
            Colors.red,
            hasTransactions,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Net Savings',
            _formatCurrency(_netSavings),
            _netSavings >= 0 ? Icons.savings : Icons.trending_down,
            _netSavings >= 0 ? Colors.blue : Colors.orange,
            hasTransactions,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool hasData,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            hasData ? value : '-',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: hasData
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    bool hasTransactions,
    List<Map<String, dynamic>> categories,
    double totalExpenses,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // ← ADD THIS
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Category Breakdown',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (hasTransactions)
                Text(
                  'Total: ${_formatCurrency(totalExpenses)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasTransactions)
            _buildEmptyState(
              'No expense data yet.\nAdd some expenses to see category breakdown.',
            )
          else if (categories.isEmpty)
            _buildEmptyState(
              'No expense categories found.\nYour income transactions are not included in this breakdown.',
            )
          else
            ...categories.map(
              (category) => _buildCategoryItem(
                category['name'] as String,
                category['amount'] as double,
                category['color'] as Color,
                category['icon'] as IconData,
                category['percentage'] as int,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String name,
    double amount,
    Color color,
    IconData icon,
    int percentage,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(amount),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                '$percentage%',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingInsights() {
    final topCategories = _topSpendingCategories;
    final netSavings = _netSavings;
    final savingsMessage = netSavings >= 0
        ? 'Great! You\'re saving ${_formatCurrency(netSavings)}'
        : 'You\'re overspending by ${_formatCurrency(netSavings.abs())}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // ← ADD THIS
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Net Savings Insight
          _buildInsightItem(
            netSavings >= 0 ? Icons.savings : Icons.warning,
            savingsMessage,
            netSavings >= 0 ? Colors.green : Colors.orange,
          ),

          // Top Category Insights
          if (topCategories.isNotEmpty) ...[
            _buildInsightItem(
              Icons.star,
              'Top spending category: ${topCategories.first['name']}',
              Colors.blue,
            ),
            if (topCategories.length >= 2)
              _buildInsightItem(
                Icons.analytics,
                '${topCategories.length} categories account for ${_calculateTopCategoriesPercentage(topCategories)}% of your spending',
                Colors.purple,
              ),
          ],

          // Transaction Count Insight
          _buildInsightItem(
            Icons.list_alt,
            'You have ${widget.transactions.length} total transactions',
            Colors.teal,
          ),
        ],
      ),
    );
  }

  int _calculateTopCategoriesPercentage(
    List<Map<String, dynamic>> topCategories,
  ) {
    final totalExpenses = _totalExpenses.abs();
    if (totalExpenses == 0) return 0;

    final topAmount = topCategories.fold(
      0.0,
      (sum, category) => sum + (category['amount'] as double),
    );
    return ((topAmount / totalExpenses) * 100).round();
  }

  Widget _buildInsightItem(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
