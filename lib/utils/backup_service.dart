import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Conditional import for path_provider (mobile only)
import 'package:flutter/foundation.dart' show kIsWeb;

// Import path_provider at the top level
import 'package:path_provider/path_provider.dart';

class BackupService {
  static const String _transactionsKey = 'transactions_data';
  static const String _backupKey = 'auto_backup_enabled';
  static const String _lastBackupKey = 'last_backup_timestamp';

  // Add this method to BackupService class
  static Future<void> triggerBackupNotification() async {
    print('Backup created notification should be shown');
  }

  // Save transactions to local storage
  static Future<void> saveTransactions(
      List<Map<String, dynamic>> transactions) async {
    try {
      // Convert transactions to serializable format
      final List<Map<String, dynamic>> serializableTransactions =
          transactions.map((transaction) {
        return {
          'title': transaction['title'],
          'amount': transaction['amount'],
          'category': transaction['category'],
          'date': transaction['date'],
          // Convert IconData to codePoint (int)
          'iconCodePoint': (transaction['icon'] as IconData).codePoint,
          // Convert Color to value (int)
          'colorValue': (transaction['color'] as Color).value,
        };
      }).toList();

      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(serializableTransactions);
      await prefs.setString(_transactionsKey, encodedData);

      // Auto backup if enabled - Skip file backup on web
      final bool backupEnabled = prefs.getBool(_backupKey) ?? true;
      if (backupEnabled && !kIsWeb) {
        await _createBackupFile(serializableTransactions);
      }

      if (kDebugMode) {
        print('Transactions saved: ${transactions.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving transactions: $e');
      }
    }
  }

  // Load transactions from local storage - FIXED IconData creation
  static Future<List<Map<String, dynamic>>> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsData = prefs.getString(_transactionsKey);

      if (transactionsData != null) {
        final List<dynamic> decodedData = jsonDecode(transactionsData);

        // Convert back from serializable format to original format
        final List<Map<String, dynamic>> transactions =
            decodedData.map<Map<String, dynamic>>((json) {
          return {
            'title': json['title'],
            'amount': json['amount'],
            'category': json['category'],
            'date': json['date'],
            // FIXED: Use constant IconData constructor
            'icon': _getIconData(json['iconCodePoint']),
            // Convert value back to Color
            'color': Color(json['colorValue']),
          };
        }).toList();

        return transactions;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading transactions: $e');
      }
    }
    return [];
  }

  // FIXED: Create IconData using constant constructor
  static IconData _getIconData(int codePoint) {
    return IconData(
      codePoint,
      fontFamily: 'MaterialIcons',
      matchTextDirection: false,
    );
  }

  // Create backup file - UPDATED with web check
  static Future<void> _createBackupFile(
      List<Map<String, dynamic>> transactions) async {
    try {
      // Skip file operations on web
      if (kIsWeb) {
        if (kDebugMode) {
          print('File backup skipped on web platform');
        }
        return;
      }

      // For mobile platforms, use path_provider
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File('${backupDir.path}/backup_$timestamp.json');

      final backupData = {
        'timestamp': timestamp,
        'date': DateTime.now().toIso8601String(),
        'transactionCount': transactions.length,
        'transactions': transactions,
      };

      await backupFile.writeAsString(jsonEncode(backupData));

      // Update last backup timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastBackupKey, timestamp);

      if (kDebugMode) {
        print('Backup created: ${backupFile.path}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating backup: $e');
      }
    }
  }

  // Get backup status - UPDATED for web
  static Future<Map<String, dynamic>> getBackupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool(_backupKey) ?? true;
    final int? lastBackup = prefs.getInt(_lastBackupKey);

    DateTime? lastBackupDate;
    if (lastBackup != null) {
      lastBackupDate = DateTime.fromMillisecondsSinceEpoch(lastBackup);
    }

    return {
      'enabled': enabled,
      'lastBackup': lastBackupDate,
      'platform': kIsWeb ? 'web' : 'mobile',
      'fileBackupSupported': !kIsWeb,
    };
  }

  // Set backup enabled/disabled
  static Future<void> setBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_backupKey, enabled);
  }

  // Export transactions as JSON string (works on web)
  static Future<String> exportTransactions() async {
    final transactions = await loadTransactions();
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'transactionCount': transactions.length,
      'transactions': transactions,
    };
    return jsonEncode(exportData);
  }

  // Import transactions from JSON string (works on web)
  static Future<void> importTransactions(String jsonData) async {
    try {
      final Map<String, dynamic> importData = jsonDecode(jsonData);
      final List<dynamic> transactionsJson = importData['transactions'];

      final List<Map<String, dynamic>> transactions =
          transactionsJson.map((json) {
        return {
          'title': json['title'],
          'amount': json['amount'],
          'category': json['category'],
          'date': json['date'],
          'icon': _getIconData(json['iconCodePoint']), // Use the fixed method
          'color': Color(json['colorValue']),
        };
      }).toList();

      await saveTransactions(transactions);
    } catch (e) {
      if (kDebugMode) {
        print('Error importing transactions: $e');
      }
      rethrow;
    }
  }
}
