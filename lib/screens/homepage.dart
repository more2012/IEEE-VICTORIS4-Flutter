import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/widgets/medical_card.dart';
import '../shared/widgets/quick_action_button.dart';
import '../shared/widgets/medication_reminder_card.dart';
import '../shared/widgets/emergency_button.dart';
import '../features/medication/controllers/medication_controller.dart';
import '../features/medication/screens/add_medication_screen.dart';
import '../features/chatbot/screens/chatbot_screen.dart';
import '../features/sos/screens/sos_screen.dart';
import '../features/medication/models/medication_model.dart'; // Add this import

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

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
      case 0: return _buildHomeContent();
      case 1: return _buildMedicationsContent();
      case 2: return const SOSScreen();
      case 3: return _buildProfileContent();
      default: return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildQuickActions(),
          const SizedBox(height: 30),
          _buildUpcomingMedications(),
          const SizedBox(height: 30),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good ${_getTimeGreeting()},',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ahmed',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.person, size: 30, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
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
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.medication,
                        size: 32,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Add New Medication',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Track your daily medications and never miss a dose',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
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
    return Consumer<MedicationController>(
      builder: (context, medicationController, child) {
        final upcomingMeds = medicationController.getUpcomingMedications();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Medications',
                  style: TextStyle(
                    fontSize: 20,
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
            const SizedBox(height: 16),

            if (upcomingMeds.isEmpty)
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
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No medications added yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Add New Medication" to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            else
            // UPDATED: Added medication object to each card
              ...upcomingMeds.map((medication) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MedicationReminderCard(
                  medicationName: '${medication.name} ${medication.dosage}',
                  time: medication.time,
                  isCompleted: medication.isTaken,
                  medication: medication, // ✅ Added this line
                  onComplete: () {
                    medicationController.toggleMedicationTaken(medication.id);
                  },
                ),
              )).toList(),
          ],
        );
      },
    );
  }

  Widget _buildMedicationsContent() {
    return Consumer<MedicationController>(
      builder: (context, medicationController, child) {
        final allMedications = medicationController.medications;

        if (allMedications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Medications',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first medication to get started',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _navigateToAddMedication,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Medication'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Medications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _navigateToAddMedication,
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // UPDATED: Added medication object to each card
              ...allMedications.map((medication) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MedicationReminderCard(
                  medicationName: '${medication.name} ${medication.dosage}',
                  time: medication.time,
                  isCompleted: medication.isTaken,
                  medication: medication, // ✅ Added this line
                  onComplete: () {
                    medicationController.toggleMedicationTaken(medication.id);
                  },
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text('Profile Screen', style: TextStyle(fontSize: 24)),
          Text('Coming soon...'),
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
        BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Medications'),
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

  void _navigateToAddMedication() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMedicationScreen(),
      ),
    );
  }

  void _navigateToChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatbotScreen(),
      ),
    );
  }
}
