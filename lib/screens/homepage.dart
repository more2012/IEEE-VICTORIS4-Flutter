import 'package:awan/screens/settings_screen.dart';
import 'package:awan/screens/sos_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../shared/widgets/medication_reminder_card.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import '../features/medication/controllers/medication_controller.dart';
import '../features/medication/screens/add_medication_screen.dart';
import '../features/chatbot/screens/chatbot_screen.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';
import 'profile_screen.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  DateTime _selectedDate = DateTime.now();

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMedications();

    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _loadMedications() {
    context.read<MedicationController>().fetchMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -8),
        child: Container(
          width: 75,
          height:75,
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
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Image.asset(
                      "assets/logos/chat-bot.png",
                      width: 28,
                      height: 28,
                      color: Colors.white,
                    ),
                    Text('ChatBot',style: TextStyle(color: Colors.white,fontSize: 14),)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          _buildMedicationsContent(),
          const SOSScreen(),
          const SettingsScreen(),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: availableHeight - 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                      const SizedBox(height: 16),
                      _buildUpcomingMedications(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
                    color: const Color(0xff0284C7),
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today, ${_formatHeaderDate(_selectedDate)}',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                height: 90,
                child: DatePicker(
                  DateTime.now().subtract(const Duration(days: 14)),
                  height: 85,
                  initialSelectedDate: _selectedDate,
                  selectionColor: const Color(0xff0284C7),
                  selectedTextColor: Colors.white,
                  dayTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                  ),
                  monthTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                  ),
                  dateTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  onDateChange: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xff0284C7),
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
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add New Medication',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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

    return Consumer<MedicationController>(
      builder: (context, medicationController, child) {
        final upcomingDoses = medicationController.getMedicationsByDate(_selectedDate);

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
            const SizedBox(height: 8),

            if (upcomingDoses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAnimatedMedicationIcon(screenWidth * 0.8),
                    const SizedBox(height: 16),
                    Text(
                      'No medications for ${_formatDateForDisplay(_selectedDate)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
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
              ...upcomingDoses.asMap().entries.map((entry) {
                final index = entry.key;
                final dose = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == upcomingDoses.length - 1 ? 0 : 12,
                  ),
                  child: MedicationReminderCard(
                    medicationName: '${dose.medication.name} ${dose.medication.dosage}',
                    time: dose.doseLabel,
                    doseDescription: dose.doseDescription,
                    isCompleted: dose.isTaken,
                    medication: dose.medication,
                    selectedDate: _selectedDate,
                    doseNumber: dose.doseNumber,
                    onComplete: () {
                      medicationController.toggleMedicationDose(
                          dose.medication.id,
                          _selectedDate,
                          dose.doseNumber
                      );
                    },
                  ),
                );
              }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedMedicationIcon(double screenWidth) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final medicationTypes = ['tablet', 'capsule', 'drop', 'injection'];
        final currentTypeIndex = (_animation.value * medicationTypes.length).floor() % medicationTypes.length;
        final currentType = medicationTypes[currentTypeIndex];

        return Container(
          width: screenWidth * 0.25,
          height: screenWidth * 0.25,
          decoration: BoxDecoration(
            color: _getMedicationColor(currentType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.125),
            border: Border.all(
              color: _getMedicationColor(currentType).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getMedicationColor(currentType).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _getMedicationIcon(currentType),
            size: screenWidth * 0.12,
            color: _getMedicationColor(currentType),
          ),
        );
      },
    );
  }

  IconData _getMedicationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return Icons.medication;
      case 'capsule':
        return Icons.medical_services;
      case 'drop':
        return Icons.water_drop;
      case 'injection':
        return Icons.vaccines;
      default:
        return Icons.medication;
    }
  }

  Color _getMedicationColor(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return Colors.blue;
      case 'capsule':
        return Colors.green;
      case 'drop':
        return Colors.cyan;
      case 'injection':
        return Colors.red;
      default:
        return Colors.blue;
    }
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
                  _buildAnimatedMedicationIcon(screenWidth),
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
                      color: Colors.black,
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

              ...allMedications.map((medication) => Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                child: MedicationReminderCard(
                  medicationName: '${medication.name} ${medication.dosage}',
                  time: medication.time,
                  isCompleted: medication.isCompletelyFinished,
                  medication: medication,
                  onComplete: () {
                    medicationController.toggleMedicationTaken(medication.id);
                  },
                ),
              )).toList(),
              SizedBox(height: screenHeight * 0.1),
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
        horizontal: screenWidth * 0.06,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: screenWidth * 0.075,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, size: 28),
                onPressed: _navigateToSettings,
              ),
            ],
          ),
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

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index == 3) {
          _navigateToSettings();
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      selectedItemColor: Color(0xff0284C7),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Medications'),
        BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'SOS'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${monthNames[date.month - 1]} ${date.day}';
  }

  String _formatDateForDisplay(DateTime date) {
    final today = DateTime.now();
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'today';
    }
    return _formatHeaderDate(date);
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