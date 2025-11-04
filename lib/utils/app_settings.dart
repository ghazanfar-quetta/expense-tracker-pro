import 'package:flutter/material.dart';
import 'backup_service.dart';

class AppSettings extends ChangeNotifier {
  String _currency = 'PKR - Pakistani Rupee';
  String _language = 'English';
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _backupEnabled = true;

  String _transactionFilterType = 'All'; // All, Income, Expense
  String _transactionSortBy = 'Date'; // Date, Amount, Category

  // ADD REPORT STATE PROPERTIES
  String _reportType = 'Summary';
  String _reportDateRange = 'Last 30 Days';
  DateTime _reportStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _reportEndDate = DateTime.now();
  bool _reportShowCustomDatePicker = false;

  AppSettings() {
    _loadBackupSetting();
  }

  // Getters
  String get currency => _currency;
  String get language => _language;
  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get backupEnabled => _backupEnabled;

  // Get currency symbol only
  String get currencySymbol => _currency.split(' - ')[0];

  // GETTERS FOR TRANSACTION FILTERS
  String get transactionFilterType => _transactionFilterType;
  String get transactionSortBy => _transactionSortBy;

  // GETTERS FOR REPORT SETTINGS
  String get reportType => _reportType;
  String get reportDateRange => _reportDateRange;
  DateTime get reportStartDate => _reportStartDate;
  DateTime get reportEndDate => _reportEndDate;
  bool get reportShowCustomDatePicker => _reportShowCustomDatePicker;

  // Setters
  void setCurrency(String newCurrency) {
    _currency = newCurrency;
    notifyListeners();
  }

  void setLanguage(String newLanguage) {
    _language = newLanguage;
    notifyListeners();
  }

  void setDarkMode(bool enabled) {
    _darkMode = enabled;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    if (!enabled) {
      _cancelAllNotifications();
    } else {
      _scheduleDefaultNotifications();
    }
    notifyListeners();
  }

  void setBackupEnabled(bool enabled) async {
    _backupEnabled = enabled;
    await BackupService.setBackupEnabled(enabled);
    notifyListeners();
  }

  // SETTERS FOR TRANSACTION FILTERS
  void setTransactionFilterType(String filterType) {
    _transactionFilterType = filterType;
    notifyListeners();
  }

  void setTransactionSortBy(String sortBy) {
    _transactionSortBy = sortBy;
    notifyListeners();
  }

  // SETTERS FOR REPORT SETTINGS
  void setReportType(String type) {
    _reportType = type;
    notifyListeners();
  }

  void setReportDateRange(String dateRange) {
    _reportDateRange = dateRange;
    notifyListeners();
  }

  void setReportDates(DateTime startDate, DateTime endDate) {
    _reportStartDate = startDate;
    _reportEndDate = endDate;
    notifyListeners();
  }

  void setReportShowCustomDatePicker(bool show) {
    _reportShowCustomDatePicker = show;
    notifyListeners();
  }

  void updateReportDateRange(String range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (range) {
      case 'Today':
        _reportStartDate = today;
        _reportEndDate = today;
        break;
      case 'Yesterday':
        _reportStartDate = today.subtract(const Duration(days: 1));
        _reportEndDate = today.subtract(const Duration(days: 1));
        break;
      case 'Last 7 Days':
        _reportStartDate = today.subtract(const Duration(days: 7));
        _reportEndDate = today;
        break;
      case 'Last 30 Days':
        _reportStartDate = today.subtract(const Duration(days: 30));
        _reportEndDate = today;
        break;
      case 'This Month':
        _reportStartDate = DateTime(now.year, now.month, 1);
        _reportEndDate = today;
        break;
      case 'Last Month':
        final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayLastMonth = DateTime(now.year, now.month, 0);
        _reportStartDate = firstDayLastMonth;
        _reportEndDate = lastDayLastMonth;
        break;
      case 'This Year':
        _reportStartDate = DateTime(now.year, 1, 1);
        _reportEndDate = today;
        break;
      case 'Custom Range':
        // Keep existing custom dates
        break;
    }
    _reportDateRange = range;
    notifyListeners();
  }

  // Load backup setting from storage
  void _loadBackupSetting() async {
    final status = await BackupService.getBackupStatus();
    _backupEnabled = status['enabled'] ?? true;
    notifyListeners();
  }

  // Placeholder methods for notification functionality
  void _cancelAllNotifications() {
    print('All notifications cancelled');
  }

  void _scheduleDefaultNotifications() {
    print('Default notifications scheduled');
  }

  // Method to trigger notifications from other parts of the app
  void triggerBudgetAlert(String message) {
    if (_notificationsEnabled) {
      print('Budget Alert: $message');
    }
  }
}
