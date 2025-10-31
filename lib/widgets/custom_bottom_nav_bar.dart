import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/stats_page.dart';
import '../pages/profile_page.dart';
import '../pages/reports_page.dart';
import '../utils/app_settings.dart';

class CustomBottomNavBar extends StatelessWidget {
  final AppSettings appSettings;
  final List<Map<String, dynamic>> transactions;
  final String currentPage; // 'home', 'stats', 'profile', 'Reports'

  const CustomBottomNavBar({
    super.key,
    required this.appSettings,
    required this.transactions,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildNavItem(
                  context, Icons.home_filled, 'Home', currentPage == 'home',
                  () {
                if (currentPage != 'home') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        appSettings: appSettings,
                        transactions: [],
                      ),
                    ),
                    (route) => false,
                  );
                }
              }),
              _buildNavItem(context, Icons.pie_chart_outline, 'Stats',
                  currentPage == 'stats', () {
                if (currentPage != 'stats') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatsPage(
                        appSettings: appSettings,
                        transactions: transactions,
                      ),
                    ),
                  );
                }
              }),
              _buildNavItem(context, Icons.person_outline, 'Profile',
                  currentPage == 'profile', () {
                if (currentPage != 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(appSettings: appSettings),
                    ),
                  );
                }
              }),
              _buildNavItem(context, Icons.info_outline, 'Reports',
                  currentPage == 'Reports', () {
                if (currentPage != 'Reports') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportsPage(
                        appSettings: appSettings,
                        transactions: transactions, // ← ADD THIS
                      ), // ← Add appSettings
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
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
