import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../shared/widgets/medication_reminder_card.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import '../features/medication/controllers/medication_controller.dart';
import '../features/medication/screens/add_medication_screen.dart';
import '../features/chatbot/screens/chatbot_screen.dart';
import '../features/sos/screens/sos_screen.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  DateTime _selectedDate = DateTime.now();

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
      // ignore parsing errors silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _navigateToChatbot,
            child: const Icon(
              Icons.chat_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildMedicationsContent();
      case 2:
        return const SOSScreen();
      case 3:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05, // 5% padding
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: screenHeight * 0.025),
          _buildQuickActions(),
          SizedBox(height: screenHeight * 0.025),
          _buildUpcomingMedications(),
          SizedBox(height: screenHeight * 0.15), // Space for floating button
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getTimeGreeting()},',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  "Hello, ${_userName.isNotEmpty ? _userName : 'User'}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0284C7),
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(screenWidth * 0.075),
            ),
            child: Icon(
              Icons.person,
              size: screenWidth * 0.08,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today , ${_formatHeaderDate(_selectedDate)}',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DatePicker(
                DateTime.now().subtract(const Duration(days: 14)),
                initialSelectedDate: _selectedDate,
                selectionColor: const Color(0xff0284C7),
                selectedTextColor: Colors.white,
                dayTextStyle: TextStyle(color: Colors.grey.shade700),
                monthTextStyle: TextStyle(color: Colors.grey.shade700),
                dateTextStyle: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
                onDateChange: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.02),

        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: screenHeight * 0.05,
            maxHeight: screenHeight * 0.07,
          ),
          decoration: BoxDecoration(
            color: Color(0xff0284C7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _navigateToAddMedication,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      size: screenWidth * 0.08,
                      color: Colors.white,
                    ),
                    // Container(
                    //   padding: EdgeInsets.all(screenWidth * 0.04),
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue.withOpacity(0.1),
                    //     borderRadius: BorderRadius.circular(16),
                    //   ),
                    //   child: Icon(
                    //     Icons.add,
                    //     size: screenWidth * 0.08,
                    //     color: Colors.blue,
                    //   ),
                    // ),
                    SizedBox(width: screenWidth * 0.10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Add New Medication',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          // Text(
                          //   'Track your daily medications and never miss a dose',
                          //   style: TextStyle(
                          //     fontSize: screenWidth * 0.035,
                          //     color: Colors.grey,
                          //   ),
                          //   maxLines: 2,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                        ],
                      ),
                    ),
                    // Icon(
                    //   Icons.arrow_forward_ios,
                    //   color: Colors.grey,
                    //   size: screenWidth * 0.04,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingMedications() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<MedicationController>(
      builder: (context, medicationController, child) {
        final upcomingMeds = medicationController.getMedicationsByDate(
          _selectedDate,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Medications',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedIndex = 1),
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            if (upcomingMeds.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.06),
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
                    Icon(
                      Icons.medication_outlined,
                      size: screenWidth * 0.12,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    Text(
                      'No medications added yet',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      'Tap "Add New Medication" to get started',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...upcomingMeds
                  .map(
                    (medication) => Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                      child: MedicationReminderCard(
                        medicationName:
                            '${medication.name} ${medication.dosage}',
                        time: medication.time,
                        isCompleted: medication.isTaken,
                        medication: medication,
                        onComplete: () {
                          medicationController.toggleMedicationTaken(
                            medication.id,
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
          ],
        );
      },
    );
  }

  Widget _buildMedicationsContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<MedicationController>(
      builder: (context, medicationController, child) {
        final allMedications = medicationController.medications;

        if (allMedications.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: screenWidth * 0.2,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'No Medications',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Add your first medication to get started',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: screenWidth * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddMedication,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Medication'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.08,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Medications',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _navigateToAddMedication,
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              ...allMedications
                  .map(
                    (medication) => Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                      child: MedicationReminderCard(
                        medicationName:
                            '${medication.name} ${medication.dosage}',
                        time: medication.time,
                        isCompleted: medication.isTaken,
                        medication: medication,
                        onComplete: () {
                          medicationController.toggleMedicationTaken(
                            medication.id,
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
              SizedBox(
                height: screenHeight * 0.1,
              ), // Bottom padding for floating button
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _navigateToSettings,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Center(
            child: Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: screenWidth * 0.18,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          Center(
            child: Text(
              _userName.isNotEmpty ? _userName : 'User',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          if (_userEmail.isNotEmpty)
            Center(
              child: Text(
                _userEmail,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          SizedBox(height: screenHeight * 0.03),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Full Name',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                      Text(
                        _userName.isNotEmpty ? _userName : '—',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                      Text(
                        _userEmail.isNotEmpty ? _userEmail : '—',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Phone',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                      Text(
                        _userPhone.isNotEmpty ? _userPhone : '—',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'Medications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'SOS'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formatHeaderDate(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = monthNames[date.month - 1];
    return '$m ${date.day}';
  }

  void _navigateToAddMedication() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
    );
  }

  void _navigateToChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatbotScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, AppConstants.settingsRoute);
  }
}
