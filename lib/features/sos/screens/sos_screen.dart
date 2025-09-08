import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  // Emergency contacts list
  List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: 'Emergency Services',
      number: '123', // Egypt emergency number
      icon: Icons.local_hospital,
      isDefault: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildInstructions(),
              const SizedBox(height: 40),
              _buildSOSButton(),
              const SizedBox(height: 40),
              _buildEmergencyContacts(),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.emergency,
          size: 60,
          color: Colors.red.shade600,
        ),
        const SizedBox(height: 16),
        const Text(
          'Emergency SOS',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Press and hold the button below for emergency help',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade600),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'How to use SOS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Hold the button for 3 seconds'),
              SizedBox(height: 4),
              Text('• Your location will be sent to emergency contacts'),
              SizedBox(height: 4),
              Text('• Emergency services (123) will be contacted'),
              SizedBox(height: 4),
              Text('• A loud alarm will sound to alert nearby people'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onTapDown: (_) => _startSOSSequence(),
      onTapUp: (_) => _cancelSOSSequence(),
      onTapCancel: () => _cancelSOSSequence(),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : _pulseAnimation.value,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade600,
                    Colors.red.shade800,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {},
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emergency,
                          size: 50,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'HOLD',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contacts, color: Colors.blue),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Add Contact Button
              ElevatedButton.icon(
                onPressed: _showAddContactDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(60, 30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // List of emergency contacts
          ..._emergencyContacts.map((contact) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildContactItem(contact),
          )).toList(),

          // Show message if no custom contacts added
          if (_emergencyContacts.length == 1)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add family members or friends to your emergency contacts',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
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

  Widget _buildContactItem(EmergencyContact contact) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: contact.isDefault ? Colors.red.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: contact.isDefault ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            contact.icon,
            size: 20,
            color: contact.isDefault ? Colors.red.shade600 : Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.number,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _callContact(contact.number),
                icon: const Icon(Icons.call, color: Colors.green, size: 18),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              if (!contact.isDefault)
                IconButton(
                  onPressed: () => _deleteContact(contact),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _startSOSSequence() {
    setState(() {
      _isPressed = true;
    });

    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(seconds: 3), () {
      if (_isPressed) {
        _triggerSOS();
      }
    });
  }

  void _cancelSOSSequence() {
    setState(() {
      _isPressed = false;
    });
  }

  void _triggerSOS() {
    setState(() {
      _isPressed = false;
    });

    // Create contacts list for the alert
    String contactsList = _emergencyContacts.map((contact) =>
    '• ${contact.name}: ${contact.number}'
    ).join('\n');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('SOS ACTIVATED'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency alert has been sent!\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('✓ Location shared with contacts'),
            const Text('✓ Emergency services (123) notified'),
            const Text('✓ Alarm activated'),
            const SizedBox(height: 16),
            const Text('Contacts notified:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(contactsList, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelSOS();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel SOS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.blue),
            SizedBox(width: 8),
            Text('Add Emergency Contact'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'e.g., Mom, Dad, Friend',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g., +20 123 456 7890',
                prefixIcon: Icon(Icons.phone),
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
              if (nameController.text.trim().isNotEmpty &&
                  numberController.text.trim().isNotEmpty) {
                _addContact(nameController.text.trim(), numberController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add Contact'),
          ),
        ],
      ),
    );
  }

  void _addContact(String name, String number) {
    setState(() {
      _emergencyContacts.add(EmergencyContact(
        name: name,
        number: number,
        icon: Icons.person,
        isDefault: false,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added to emergency contacts'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteContact(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to remove ${contact.name} from emergency contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _emergencyContacts.remove(contact);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${contact.name} removed from emergency contacts'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _cancelSOS() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS alert cancelled'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _callContact(String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $number...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Emergency Contact Model
class EmergencyContact {
  final String name;
  final String number;
  final IconData icon;
  final bool isDefault;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.icon,
    this.isDefault = false,
  });
}
