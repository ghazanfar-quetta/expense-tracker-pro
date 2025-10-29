import 'package:flutter/material.dart';
import '../utils/app_settings.dart';
import 'add_transaction_page.dart';

class AllTransactionsPage extends StatefulWidget {
  final AppSettings appSettings;
  final List<Map<String, dynamic>> transactions;
  final Function(Map<String, dynamic>)? onTransactionDeleted;

  const AllTransactionsPage({
    super.key,
    required this.appSettings,
    required this.transactions,
    this.onTransactionDeleted,
  });

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  List<Map<String, dynamic>> get _filteredTransactions {
    List<Map<String, dynamic>> filtered = List.from(widget.transactions);

    // Apply filter
    if (widget.appSettings.transactionFilterType == 'Income') {
      filtered = filtered.where((t) => t['amount'] > 0).toList();
    } else if (widget.appSettings.transactionFilterType == 'Expense') {
      filtered = filtered.where((t) => t['amount'] < 0).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (widget.appSettings.transactionSortBy) {
        case 'Amount':
          return (b['amount'] as double).compareTo(a['amount'] as double);
        case 'Category':
          return (a['category'] as String).compareTo(b['category'] as String);
        case 'Date':
        default:
          return (b['date'] as String).compareTo(a['date'] as String);
      }
    });

    return filtered;
  }

  String _formatCurrency(double amount) {
    return '${widget.appSettings.currencySymbol} ${amount.abs().toStringAsFixed(2)}';
  }

  // DELETE METHOD
  void _deleteTransaction(Map<String, dynamic> transaction) {
    final deletedTransaction = Map<String, dynamic>.from(transaction);
    final deletedIndex = widget.transactions.indexOf(transaction);

    // Remove from the main transactions list
    widget.transactions
        .removeAt(deletedIndex); // Use removeAt instead of remove

    // Notify parent (home page) about the deletion
    if (widget.onTransactionDeleted != null) {
      widget.onTransactionDeleted!(deletedTransaction);
    }

    // Update UI
    setState(() {});

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // Restore the transaction at the original index
            widget.transactions.insert(deletedIndex, deletedTransaction);
            if (widget.onTransactionDeleted != null) {
              widget.onTransactionDeleted!(deletedTransaction);
            }
            setState(() {});
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
        title: const Text(
          'All Transactions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_filteredTransactions.length} transactions',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${widget.appSettings.transactionFilterType} • Sorted by ${widget.appSettings.transactionSortBy}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          // Transactions list
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return _buildTransactionItem(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // TRANSACTION ITEM METHOD WITH DELETE
  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final bool isIncome = transaction['amount'] > 0;

    return Dismissible(
      key: Key(transaction['title'] +
          transaction['amount'].toString() +
          transaction['date']),
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
                  const SizedBox(height: 4),
                  Text(
                    transaction['date'] as String,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isIncome
                      ? '+ ${_formatCurrency(transaction['amount'] as double)}'
                      : '- ${_formatCurrency((transaction['amount'] as double).abs())}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isIncome ? 'INCOME' : 'EXPENSE',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // EDIT BUTTON
                GestureDetector(
                  onTap: () {
                    _editTransaction(transaction);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filter settings',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _editTransaction(Map<String, dynamic> transaction) async {
    // Store the original index before navigation
    final originalIndex = widget.transactions.indexOf(transaction);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          appSettings: widget.appSettings,
          transactionToEdit: transaction,
        ),
      ),
    );

    if (result != null && originalIndex != -1) {
      // Replace the transaction at the original index
      widget.transactions[originalIndex] = result;

      // Notify parent to save changes
      if (widget.onTransactionDeleted != null) {
        widget.onTransactionDeleted!(result);
      }

      // Force UI refresh
      setState(() {});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter & Sort'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter by type
            const Text('Filter by Type:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['All', 'Income', 'Expense'].map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: widget.appSettings.transactionFilterType == type,
                  onSelected: (selected) {
                    widget.appSettings.setTransactionFilterType(type);
                    setState(() {});
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Sort by
            const Text('Sort by:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Date', 'Amount', 'Category'].map((sort) {
                return ChoiceChip(
                  label: Text(sort),
                  selected: widget.appSettings.transactionSortBy == sort,
                  onSelected: (selected) {
                    widget.appSettings.setTransactionSortBy(sort);
                    setState(() {});
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
