import 'package:flutter/material.dart';
import '../utils/app_settings.dart';
import '../utils/backup_service.dart';

class ProfilePage extends StatefulWidget {
  final AppSettings appSettings;

  const ProfilePage({super.key, required this.appSettings});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'Your Name';
  String _userEmail = 'Your Email Address';
  DateTime? _lastBackup;

  final List<String> _currencies = [
    'Rs. - Pakistani Rupee',
    'USD - US Dollar',
    'EUR - Euro',
    'GBP - British Pound',
    'INR - Indian Rupee',
    'JPY - Japanese Yen',
    'CNY - Chinese Yuan',
    'CAD - Canadian Dollar',
    'AUD - Australian Dollar',
    'CHF - Swiss Franc',
  ];

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese (Simplified)',
    'Arabic',
    'Hindi',
    'Portuguese',
    'Russian',
    'Japanese',
    'Urdu',
    'Turkish',
    'Italian',
  ];

  @override
  void initState() {
    super.initState();
    widget.appSettings.addListener(_onSettingsChanged);
    _loadBackupStatus();
  }

  @override
  void dispose() {
    widget.appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  void _loadBackupStatus() async {
    final status = await BackupService.getBackupStatus();
    setState(() {
      _lastBackup = status['lastBackup'];
    });
  }

  String _formatBackupDate(DateTime? date) {
    if (date == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile & Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Settings
            _buildSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_userEmail, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Profile Info',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: _editProfile),
        ],
      ),
    );
  }

  void _editProfile() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userName = nameController.text.trim();
                _userEmail = emailController.text.trim();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            Icons.notifications,
            'Notifications',
            widget.appSettings.notificationsEnabled,
            (value) {
              widget.appSettings.setNotificationsEnabled(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Notifications ${value ? 'enabled' : 'disabled'}',
                  ),
                  backgroundColor: value ? Colors.green : Colors.grey,
                ),
              );
            },
          ),
          _buildSettingItem(
            Icons.language,
            'Language',
            false,
            (value) => _showLanguageDialog(),
            showSwitch: false,
            valueText: widget.appSettings.language,
          ),
          _buildSettingItem(
            Icons.dark_mode,
            'Dark Mode',
            widget.appSettings.darkMode,
            (value) {
              widget.appSettings.setDarkMode(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dark Mode ${value ? 'enabled' : 'disabled'}'),
                  backgroundColor: value ? Colors.deepPurple : Colors.grey,
                ),
              );
            },
          ),
          _buildSettingItem(
            Icons.currency_exchange,
            'Currency',
            false,
            (value) => _showCurrencyDialog(),
            showSwitch: false,
            valueText: widget.appSettings.currency.split(' - ')[0],
          ),
          _buildSettingItem(
            Icons.backup,
            'Auto Backup',
            widget.appSettings.backupEnabled,
            (value) {
              widget.appSettings.setBackupEnabled(value);
              _loadBackupStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Auto Backup ${value ? 'enabled' : 'disabled'}',
                  ),
                  backgroundColor: value ? Colors.blue : Colors.grey,
                ),
              );
            },
            subtitle: 'Last backup: ${_formatBackupDate(_lastBackup)}',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    bool isActive,
    Function(bool) onChanged, {
    bool showSwitch = true,
    String valueText = '',
    String subtitle = '',
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (valueText.isNotEmpty)
                  Text(
                    valueText,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
              ],
            ),
          ),
          if (showSwitch)
            Switch(
              value: isActive,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            )
          else
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () => onChanged(false),
            ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              return ListTile(
                title: Text(language),
                trailing: language == widget.appSettings.language
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  widget.appSettings.setLanguage(language);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to $language'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _currencies.length,
            itemBuilder: (context, index) {
              final currency = _currencies[index];
              return ListTile(
                title: Text(currency),
                trailing: currency == widget.appSettings.currency
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  widget.appSettings.setCurrency(currency);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Currency changed to ${currency.split(' - ')[0]}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
