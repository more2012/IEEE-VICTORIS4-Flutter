import 'package:awan/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    try {
      final userJsonString = StorageService.getString('user_data');
      if (userJsonString != null && userJsonString.isNotEmpty) {
        final userMap = json.decode(userJsonString) as Map<String, dynamic>;
        setState(() {
          _userName = (userMap['full_name'] ?? '').toString();
          _userEmail = (userMap['email'] ?? '').toString();
          _userPhone = (userMap['phone'] ?? '').toString();
        });
      }
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xff0284C7),
        foregroundColor: Colors.black,
        elevation: 2,
        centerTitle: false,
        title: Text(
          //textAlign: TextAlign.left,
          'Profile',
          style: TextStyle(
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.settings, size: 28),
              onPressed: _navigateToSettings,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.03),
            CircleAvatar(
              radius: screenWidth * 0.18,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.person,
                size: screenWidth * 0.2,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            Text(
              _userName.isNotEmpty ? _userName : 'User',
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.01),

            if (_userEmail.isNotEmpty)
              Text(
                _userEmail,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: screenWidth * 0.045,
                ),
                textAlign: TextAlign.center,
              ),

            SizedBox(height: screenHeight * 0.04),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Full Name',
                      value: _userName.isNotEmpty ? _userName : '—',
                      screenWidth: screenWidth,
                    ),
                    Divider(color: Colors.grey.shade300, height: 24),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _userEmail.isNotEmpty ? _userEmail : '—',
                      screenWidth: screenWidth,
                    ),
                    Divider(color: Colors.grey.shade300, height: 24),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: _userPhone.isNotEmpty ? _userPhone : '—',
                      screenWidth: screenWidth,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required double screenWidth,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context,AppConstants.settingsRoute );
  }
}