import 'package:flutter/material.dart';
import 'stats_page.dart';
import 'about_page.dart';
import 'profile_page.dart';
import 'add_transaction_page.dart';
import 'notifications_page.dart';
import 'all_transactions_page.dart';
import '../utils/app_settings.dart';
import '../utils/backup_service.dart';

class HomePage extends StatefulWidget {
  final AppSettings appSettings;

  const HomePage({super.key, required this.appSettings});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    widget.appSettings.addListener(_onSettingsChanged);
    _loadTransactions();
  }

  @override
  void dispose() {
    widget.appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  // Load transactions from storage
  void _loadTransactions() async {
    final transactions = await BackupService.loadTransactions();
    setState(() {
      _recentTransactions = transactions;
    });
  }

  // Save transactions and trigger backup if enabled
  void _saveTransactions() async {
    await BackupService.saveTransactions(_recentTransactions);
  }

  void _deleteTransaction(Map<String, dynamic> transaction) {
    // Store the deleted transaction for undo
    final deletedTransaction = transaction;
    final deletedIndex = _recentTransactions.indexOf(transaction);

    setState(() {
      _recentTransactions.remove(transaction);
    });

    _saveTransactions(); // Save to storage

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _recentTransactions.insert(deletedIndex, deletedTransaction);
            });
            _saveTransactions(); // Save the undo
          },
        ),
      ),
    );
  }

  // Calculate totals from actual transactions
  double get _totalBalance {
    return _recentTransactions.fold(
      0,
      (sum, transaction) => sum + (transaction['amount'] as double),
    );
  }

  double get _totalIncome {
    return _recentTransactions
        .where((transaction) => transaction['amount'] > 0)
        .fold(0, (sum, transaction) => sum + (transaction['amount'] as double));
  }

  double get _totalExpenses {
    return _recentTransactions
        .where((transaction) => transaction['amount'] < 0)
        .fold(0, (sum, transaction) => sum + (transaction['amount'] as double));
  }

  // Currency formatting methods
  // For total balance - shows actual value with proper sign
  String _formatBalance(double amount) {
    final String symbol = widget.appSettings.currencySymbol;
    final bool isNegative = amount < 0;
    final double absAmount = amount.abs();

    if (absAmount >= 1000000000) {
      return '${isNegative ? '-' : ''}$symbol ${(absAmount / 1000000000).toStringAsFixed(1)}B';
    } else if (absAmount >= 1000000) {
      return '${isNegative ? '-' : ''}$symbol ${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      return '${isNegative ? '-' : ''}$symbol ${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      return '${isNegative ? '-' : ''}$symbol ${absAmount.toStringAsFixed(2)}';
    }
  }

  // For individual transaction amounts - shows absolute value with + for income, - for expense
  String _formatTransactionAmount(double amount) {
    final String symbol = widget.appSettings.currencySymbol;
    final bool isIncome = amount > 0;
    final double absAmount = amount.abs();

    if (absAmount >= 1000000000) {
      return '${isIncome ? '+' : '-'}$symbol ${(absAmount / 1000000000).toStringAsFixed(1)}B';
    } else if (absAmount >= 1000000) {
      return '${isIncome ? '+' : '-'}$symbol ${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      return '${isIncome ? '+' : '-'}$symbol ${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      return '${isIncome ? '+' : '-'}$symbol ${absAmount.toStringAsFixed(2)}';
    }
  }

  // Keep the original for other uses where we want absolute values
  String _formatCurrency(double amount) {
    final String symbol = widget.appSettings.currencySymbol;
    final double absAmount = amount.abs();

    if (absAmount >= 1000000000) {
      return '$symbol ${(absAmount / 1000000000).toStringAsFixed(1)}B';
    } else if (absAmount >= 1000000) {
      return '$symbol ${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      return '$symbol ${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol ${absAmount.toStringAsFixed(2)}';
    }
  }

  void _viewAllTransactions() {
    if (_recentTransactions.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllTransactionsPage(
          appSettings: widget.appSettings,
          transactions: _recentTransactions,
          onTransactionDeleted: (deletedTransaction) {
            // This will be called when a transaction is deleted from AllTransactionsPage
            setState(() {
              // The transaction is already removed from the list
              // We just need to save the changes
              _saveTransactions();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: const Text(
          'Expense Tracker Pro',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationsPage(appSettings: widget.appSettings),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            _buildBalanceCard(),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(),
            const SizedBox(height: 24),

            // Recent Transactions Header
            _buildSectionHeader('Recent Transactions', 'View All'),
            const SizedBox(height: 16),

            // Transactions List (shows empty state if no transactions)
            _recentTransactions.isEmpty
                ? _buildEmptyState()
                : _buildTransactionsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionPage(
                appSettings: widget.appSettings,
              ),
            ),
          );

          if (result != null) {
            // Add the new transaction to the list and save
            setState(() {
              _recentTransactions.insert(0, result);
            });
            _saveTransactions(); // Save after adding transaction
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatBalance(_totalBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBalanceIndicator(
                'Income',
                _totalIncome,
                Colors.green.shade50,
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildBalanceIndicator(
                'Expenses',
                _totalExpenses.abs(),
                Colors.red.shade50,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceIndicator(
    String title,
    double amount,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _formatCurrency(amount),
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    // Calculate weekly average based on actual expenses
    double weeklyAverage =
        _recentTransactions.isEmpty ? 0 : _totalExpenses.abs() / 4;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Weekly Avg',
            _formatCurrency(weeklyAverage),
            Icons.trending_up,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Monthly',
            _formatCurrency(_totalExpenses.abs()),
            Icons.bar_chart,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Transactions',
            _recentTransactions.length.toString(),
            Icons.list,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 24,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // ← ADD THIS
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: _recentTransactions.isEmpty ? null : _viewAllTransactions,
            child: Text(
              actionText,
              style: TextStyle(
                color: _recentTransactions.isEmpty
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first income or expense',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    // Show only recent transactions (last 5-10) on home page
    final recentToShow = _recentTransactions.take(5).toList();

    return Column(
      children: recentToShow
          .map((transaction) => _buildTransactionItem(transaction))
          .toList(),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final bool isIncome = transaction['amount'] > 0;

    return Dismissible(
      key: Key(transaction['title'] +
          transaction['amount'].toString()), // Unique key
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      onDismissed: (direction) {
        _deleteTransaction(transaction);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (transaction['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                transaction['icon'] as IconData,
                color: transaction['color'] as Color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['category'] as String,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatTransactionAmount(transaction['amount'] as double),
                      style: TextStyle(
                        color: isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction['date'] as String,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_filled, 'Home', true, () {
                // Already on home page
              }),
              _buildNavItem(Icons.pie_chart_outline, 'Stats', false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatsPage(
                      appSettings: widget.appSettings,
                      transactions: _recentTransactions,
                    ),
                  ),
                );
              }),
              _buildNavItem(Icons.person_outline, 'Profile', false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(appSettings: widget.appSettings),
                  ),
                );
              }),
              _buildNavItem(Icons.info_outline, 'About', false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AboutPage(appSettings: widget.appSettings)),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[400],
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
