import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Account', screenWidth),
                _buildTile(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: 'Manage your information',
                ),
                _buildTile(
                  icon: Icons.lock_outline,
                  title: 'Privacy',
                  subtitle: 'Passwords, permissions',
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Notifications', screenWidth),
                _buildTile(
                  icon: Icons.notifications_outlined,
                  title: 'Reminders',
                  subtitle: 'Medication alerts',
                ),
                _buildTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Sounds',
                  subtitle: 'Alert tones and volume',
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('About', screenWidth),
                _buildTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  subtitle: '1.0.0',
                ),
                _buildTile(
                  icon: Icons.article_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Text(
              "© 2025 D3adL0ck Team. All rights reserved.",
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          radius: 22,
          child: Icon(icon, color: Colors.blue, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
