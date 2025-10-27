import 'package:flutter/material.dart';
import '../utils/app_settings.dart';

class AddTransactionPage extends StatefulWidget {
  final AppSettings appSettings;

  const AddTransactionPage({super.key, required this.appSettings});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = 'Salary';
  String _transactionType = 'Expense';
  DateTime _selectedDate = DateTime.now();

  // Separate categories for Income and Expense
  final List<String> _incomeCategories = [
    'Salary',
    'Bonus',
    'Freelance',
    'Investment',
    'Gift',
    'Business',
    'Other Income',
  ];

  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Healthcare',
    'Education',
    'Rent',
    'Travel',
    'Other Expense',
  ];

  // Listen to settings changes
  @override
  void initState() {
    super.initState();
    // Set initial category based on transaction type
    _selectedCategory = _currentCategories.first;
    // Add listener for settings changes
    widget.appSettings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    widget.appSettings.removeListener(_onSettingsChanged);
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {}); // Rebuild when currency changes
  }

  // Get current categories based on transaction type
  List<String> get _currentCategories {
    return _transactionType == 'Income'
        ? _incomeCategories
        : _expenseCategories;
  }

  // Helper methods to get icon and color for categories
  IconData _getCategoryIcon(String category) {
    if (_transactionType == 'Income') {
      switch (category) {
        case 'Salary':
          return Icons.work;
        case 'Bonus':
          return Icons.celebration;
        case 'Freelance':
          return Icons.computer;
        case 'Investment':
          return Icons.trending_up;
        case 'Gift':
          return Icons.card_giftcard;
        case 'Business':
          return Icons.business_center;
        case 'Other Income':
          return Icons.attach_money;
        default:
          return Icons.money;
      }
    } else {
      switch (category) {
        case 'Food':
          return Icons.restaurant;
        case 'Transport':
          return Icons.directions_car;
        case 'Shopping':
          return Icons.shopping_bag;
        case 'Entertainment':
          return Icons.movie;
        case 'Bills':
          return Icons.receipt;
        case 'Healthcare':
          return Icons.local_hospital;
        case 'Education':
          return Icons.school;
        case 'Rent':
          return Icons.home;
        case 'Travel':
          return Icons.flight;
        case 'Other Expense':
          return Icons.shopping_cart;
        default:
          return Icons.category;
      }
    }
  }

  Color _getCategoryColor(String category) {
    if (_transactionType == 'Income') {
      switch (category) {
        case 'Salary':
          return Colors.green;
        case 'Bonus':
          return Colors.amber;
        case 'Freelance':
          return Colors.blue;
        case 'Investment':
          return Colors.purple;
        case 'Gift':
          return Colors.pink;
        case 'Business':
          return Colors.teal;
        case 'Other Income':
          return Colors.green.shade700;
        default:
          return Colors.green;
      }
    } else {
      switch (category) {
        case 'Food':
          return Colors.orange;
        case 'Transport':
          return Colors.blue;
        case 'Shopping':
          return Colors.purple;
        case 'Entertainment':
          return Colors.red;
        case 'Bills':
          return Colors.green;
        case 'Healthcare':
          return Colors.pink;
        case 'Education':
          return Colors.teal;
        case 'Rent':
          return Colors.brown;
        case 'Travel':
          return Colors.cyan;
        case 'Other Expense':
          return Colors.grey;
        default:
          return Colors.red;
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTransaction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Transaction Type Selector
              _buildTypeSelector(),
              const SizedBox(height: 24),

              // Amount Input
              _buildAmountInput(),
              const SizedBox(height: 24),

              // Title Input
              _buildTitleInput(),
              const SizedBox(height: 24),

              // Category Selector
              _buildCategorySelector(),
              const SizedBox(height: 24),

              // Date Picker
              _buildDatePicker(),
              const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _transactionType = 'Expense';
                  // Reset to first category of the new type
                  _selectedCategory = _currentCategories.first;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _transactionType == 'Expense'
                      ? Colors.red
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Expense',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _transactionType == 'Expense'
                        ? Colors.white
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _transactionType = 'Income';
                  // Reset to first category of the new type
                  _selectedCategory = _currentCategories.first;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _transactionType == 'Income'
                      ? Colors.green
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Income',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _transactionType == 'Income'
                        ? Colors.white
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: '${widget.appSettings.currencySymbol} ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid amount';
        }
        if (double.parse(value) <= 0) {
          return 'Amount must be greater than 0';
        }
        return null;
      },
    );
  }

  Widget _buildTitleInput() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Enter transaction title',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category - $_transactionType',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _currentCategories.map((category) {
            final isSelected = category == _selectedCategory;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getCategoryColor(category).withOpacity(0.8)
                      : _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _getCategoryColor(category)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: isSelected
                          ? Colors.white
                          : _getCategoryColor(category),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : _getCategoryColor(category),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor:
              _transactionType == 'Income' ? Colors.green : Colors.red,
        ),
        child: Text(
          'Save $_transactionType',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      // Create the transaction with proper data structure
      final Map<String, dynamic> newTransaction = {
        'title': _titleController.text,
        'amount': _transactionType == 'Expense'
            ? -double.parse(_amountController.text)
            : double.parse(_amountController.text),
        'category': _selectedCategory,
        'date': _formatDate(_selectedDate),
        'icon': _getCategoryIcon(_selectedCategory),
        'color': _getCategoryColor(_selectedCategory),
      };

      // Return the new transaction to the previous page
      Navigator.of(context).pop(newTransaction);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_transactionType added successfully!'),
          backgroundColor:
              _transactionType == 'Income' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
