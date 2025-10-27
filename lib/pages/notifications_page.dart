import 'package:flutter/material.dart';
import '../utils/app_settings.dart';

class NotificationsPage extends StatefulWidget {
  final AppSettings appSettings;

  const NotificationsPage({super.key, required this.appSettings});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _notifications = [];

  // Clear all notifications
  void _clearAllNotifications() {
    setState(() {
      _notifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications cleared')),
    );
  }

  // Mark all notifications as read
  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  // Method to add notifications from other parts of the app
  void addNotification({
    required String title,
    required String message,
    required String type,
  }) {
    if (!widget.appSettings.notificationsEnabled) return;

    setState(() {
      _notifications.insert(0, {
        'title': title,
        'message': message,
        'time': 'Just now',
        'read': false,
        'type': type,
        'timestamp': DateTime.now(),
      });
    });
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          if (_notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllNotifications,
              tooltip: 'Clear all notifications',
            ),
          ],
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                // Update time display
                notification['time'] = _formatTime(notification['timestamp']);
                return _buildNotificationItem(notification, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifications will appear here\nwhen you use the app',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    Color getNotificationColor(String type) {
      switch (type) {
        case 'alert':
          return Colors.red;
        case 'income':
          return Colors.green;
        case 'reminder':
          return Colors.orange;
        case 'summary':
          return Colors.blue;
        case 'info':
          return Colors.purple;
        case 'backup':
          return Colors.teal;
        default:
          return Colors.blue;
      }
    }

    IconData getNotificationIcon(String type) {
      switch (type) {
        case 'alert':
          return Icons.warning;
        case 'income':
          return Icons.arrow_upward;
        case 'reminder':
          return Icons.calendar_today;
        case 'summary':
          return Icons.analytics;
        case 'info':
          return Icons.info;
        case 'backup':
          return Icons.backup;
        default:
          return Icons.notifications;
      }
    }

    return Dismissible(
      key: Key('notification_${notification['timestamp']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        final dismissedNotification = _notifications[index];
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification dismissed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _notifications.insert(index, dismissedNotification);
                });
              },
            ),
          ),
        );
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
          border: !notification['read']
              ? Border.all(
                  color: getNotificationColor(
                    notification['type'],
                  ).withOpacity(0.3),
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getNotificationColor(
                  notification['type'],
                ).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getNotificationIcon(notification['type']),
                color: getNotificationColor(notification['type']),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !notification['read']
                          ? Theme.of(context).colorScheme.onBackground
                          : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'],
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['time'],
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (!notification['read'])
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: getNotificationColor(notification['type']),
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[500],
                    size: 16,
                  ),
                  onPressed: () {
                    _showNotificationOptions(notification, index);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationOptions(Map<String, dynamic> notification, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notification['read'])
              ListTile(
                leading: const Icon(Icons.mark_as_unread),
                title: const Text('Mark as Unread'),
                onTap: () {
                  setState(() {
                    _notifications[index]['read'] = false;
                  });
                  Navigator.pop(context);
                },
              ),
            if (!notification['read'])
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: const Text('Mark as Read'),
                onTap: () {
                  setState(() {
                    _notifications[index]['read'] = true;
                  });
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                setState(() {
                  _notifications.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification deleted')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
