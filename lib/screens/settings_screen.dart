import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _currentUserEmail = '';
  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final authController = context.read<AuthController>();
    final userData = authController.getCurrentUserData();

    if (userData != null) {
      setState(() {
        _currentUserName = userData['full_name'] ?? '';
        _currentUserEmail = userData['email'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xff0284C7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            if (_currentUserName.isNotEmpty) ...[
              _buildSectionHeader('Account Information', screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _buildUserInfoCard(screenWidth),
              SizedBox(height: screenHeight * 0.03),
            ],

            // Notification Settings
            _buildSectionHeader('Notifications', screenWidth),
            SizedBox(height: screenHeight * 0.01),
            _buildNotificationSettings(screenWidth),
            SizedBox(height: screenHeight * 0.03),

            // App Settings
            _buildSectionHeader('App Settings', screenWidth),
            SizedBox(height: screenHeight * 0.01),
            _buildAppSettings(screenWidth),
            SizedBox(height: screenHeight * 0.03),

            // Danger Zone
            _buildSectionHeader('Account', screenWidth),
            SizedBox(height: screenHeight * 0.01),
            _buildDangerZone(screenWidth),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
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

  Widget _buildUserInfoCard(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.08,
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  Icons.person,
                  size: screenWidth * 0.1,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUserName,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      _currentUserEmail,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Medication Reminders',
            subtitle: 'Receive notifications for medication times',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _handleNotificationToggle(value);
              },
              activeColor: Colors.blue,
            ),
            onTap: null,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.schedule,
            title: 'Notification Schedule',
            subtitle: 'Manage notification timing',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle notification schedule settings
              _showNotificationScheduleDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version 1.0.0',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog();
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with using the app',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showHelpDialog();
            },
          ),
          // const Divider(height: 1),
          // _buildSettingsTile(
          //   icon: Icons.bug_report_outlined,
          //   title: 'Debug Info',
          //   subtitle: 'View app debug information',
          //   trailing: const Icon(Icons.chevron_right),
          //   onTap: () {
          //     _showDebugInfo();
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: () => _showLogoutDialog(),
            titleColor: Colors.red,
            iconColor: Colors.red,
          ),
          const Divider(height: 1, color: Colors.red),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Remove all stored data from this device',
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: () => _showClearDataDialog(),
            titleColor: Colors.red,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.blue,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _handleNotificationToggle(bool enabled) async {
    if (enabled) {
      final hasPermission = await NotificationService.requestPermissions();
      if (!hasPermission) {
        setState(() {
          _notificationsEnabled = false;
        });
        _showPermissionDialog();
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? You will need to sign in again next time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Perform logout
              await context.read<AuthController>().logout();

              // Close loading and navigate
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                      (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will remove all your medications, settings, and account data from this device. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Clear all data
              await StorageService.clear();
              await NotificationService.cancelAllNotifications();

              // Logout
              await context.read<AuthController>().logout();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                      (route) => false,
                );
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Permission'),
        content: const Text('Please enable notifications in your device settings to receive medication reminders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotificationScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Schedule'),
        content: const Text('Notifications are sent at the times you set for each medication.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Awan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Awan - Medication Reminder App'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('Build: 1'),
            SizedBox(height: 16),
            Text('A simple and effective way to manage your medication schedule.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('For help with the app or to report issues, please contact support@awan.app'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  // void _showDebugInfo() async {
  //   final pendingNotifications = await NotificationService.getPendingNotifications();
  //
  //   if (!mounted) return;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Debug Information'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Storage Keys: ${StorageService.getStorageSize()}'),
  //             const SizedBox(height: 8),
  //             Text('Pending Notifications: ${pendingNotifications.length}'),
  //             const SizedBox(height: 8),
  //             Text('User Logged In: ${context.read<AuthController>().isLoggedIn}'),
  //             const SizedBox(height: 8),
  //             const Text('Tap "Show Details" for more info.'),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             StorageService.debugPrintAllData();
  //             Navigator.pop(context);
  //           },
  //           child: const Text('Show Details'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
