import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Account', screenWidth),
          _buildTile(
            Icons.person_outline,
            'Profile',
            'Manage your information',
          ),
          _buildTile(Icons.lock_outline, 'Privacy', 'Passwords, permissions'),
          const SizedBox(height: 16),
          _buildSectionTitle('Notifications', screenWidth),
          _buildTile(
            Icons.notifications_outlined,
            'Reminders',
            'Medication alerts',
          ),
          _buildTile(
            Icons.volume_up_outlined,
            'Sounds',
            'Alert tones and volume',
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('About', screenWidth),
          _buildTile(Icons.info_outline, 'Version', '1.0.0'),
          _buildTile(
            Icons.article_outlined,
            'Terms of Service',
            'Read our terms',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
