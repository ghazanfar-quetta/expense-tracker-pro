import 'package:flutter/material.dart';
import 'backup_service.dart';

class AppSettings extends ChangeNotifier {
  String _currency = 'PKR - Pakistani Rupee';
  String _language = 'English';
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _backupEnabled = true;

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
      // Cancel all scheduled notifications when disabled
      _cancelAllNotifications();
    } else {
      // Schedule notifications when enabled
      _scheduleDefaultNotifications();
    }
    notifyListeners();
  }

  void setBackupEnabled(bool enabled) async {
    _backupEnabled = enabled;
    await BackupService.setBackupEnabled(enabled);
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
    // This would integrate with flutter_local_notifications
    print('All notifications cancelled');
  }

  void _scheduleDefaultNotifications() {
    // This would integrate with flutter_local_notifications
    print('Default notifications scheduled');
  }

  // Method to trigger notifications from other parts of the app
  void triggerBudgetAlert(String message) {
    if (_notificationsEnabled) {
      // This would show actual local notifications
      print('Budget Alert: $message');
    }
  }
}
