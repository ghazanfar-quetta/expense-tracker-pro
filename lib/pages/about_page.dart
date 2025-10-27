import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // FIXED
      appBar: AppBar(
        title: const Text(
          'About Developer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // FIXED
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor, // FIXED
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Developer Profile Card
            _buildDeveloperCard(context),
            const SizedBox(height: 24),

            // Contact Information
            _buildContactSection(context),
            const SizedBox(height: 24),

            // App Information
            _buildAppInfoSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7C3AED),
            const Color(0xFF7C3AED).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Developer Photo/Icon
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              Icons.code,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ghazanfar Ali',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Flutter Developer, Web Page, Windows & Mobile App Specialist',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Cell #: 03118282727',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // FIXED
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
          Text(
            'Get In Touch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground, // FIXED
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s work together to bring your ideas to life! I specialize in creating beautiful, high-performance mobile applications.',
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7), // FIXED
                fontSize: 14),
          ),
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, children: []),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // FIXED
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
          Text(
            'About Expense Tracker Pro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground, // FIXED
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Expense Tracker Pro is a modern, feature-rich financial management app designed to help users track their income and expenses effortlessly. Built with Flutter, it showcases clean architecture, responsive design, and excellent user experience.',
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7), // FIXED
                fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(context, 'Version', '1.0.0'),
              const SizedBox(width: 20),
              _buildInfoItem(context, 'Flutter', '3.19.0'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoItem(context, 'Last Update', 'March 2024'),
              const SizedBox(width: 20),
              _buildInfoItem(context, 'Platform', 'Android/iOS/Web'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6), // FIXED
                  fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onBackground, // FIXED
              )),
        ],
      ),
    );
  }
}
