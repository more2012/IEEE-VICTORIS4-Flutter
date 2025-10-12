import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../services/api_service.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;
  Timer? _longPressTimer;
  Position? _currentPosition;
  String _currentLocationMessage = 'Getting your location...';
  bool _isLoadingContacts = true;

  List<EmergencyContact> _emergencyContacts = [];

  final EmergencyContact _defaultEmergency = EmergencyContact(
    name: 'Emergency Services',
    number: '123',
    relationship: 'Emergency',
    isDefault: true,
  );

  final List<String> _relationships = [
    'Family',
    'Friend',
    'Doctor',
    'Hospital',
    'Other'
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
    _fetchEmergencyContacts();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchEmergencyContacts() async {
    setState(() {
      _isLoadingContacts = true;
    });
    try {
      final response = await ApiService.get('/emergency/contacts/');
      final List<dynamic> contactsJson = response as List<dynamic>;
      _emergencyContacts = contactsJson.map((json) => EmergencyContact.fromJson(json)).toList();
      _emergencyContacts.insert(0, _defaultEmergency);
      print('✅ Fetched emergency contacts from backend');
    } catch (e) {
      print('⚠️ Error fetching emergency contacts: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingContacts = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _updateLocationMessage('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _updateLocationMessage('Location permissions are permanently denied.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _currentLocationMessage =
        'Location: Lat ${position.latitude.toStringAsFixed(4)}, Lon ${position.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      _updateLocationMessage('Failed to get location: ${e.toString()}');
    }
  }

  void _updateLocationMessage(String message) {
    setState(() {
      _currentLocationMessage = message;
    });
  }

  void _startSOSSequence() {
    setState(() {
      _isPressed = true;
    });
    HapticFeedback.heavyImpact();

    _longPressTimer = Timer(const Duration(seconds: 2), () {
      if (_isPressed) {
        _triggerSOS();
      }
    });
  }

  void _cancelSOSSequence() {
    _longPressTimer?.cancel();
    setState(() {
      _isPressed = false;
    });
  }

  Future<void> _triggerSOS() async {
    _longPressTimer?.cancel();
    setState(() {
      _isPressed = false;
    });

    final locationLink = _currentPosition != null
        ? 'http://maps.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        : 'Location unavailable';

    final contactsToSend =
    _emergencyContacts.where((c) => !c.isDefault).toList();

    for (var contact in contactsToSend) {
      final message =
          'EMERGENCY ALERT: I need immediate help. My last known location is: $locationLink';
      final Uri uri = Uri.parse(
          'sms:${contact.number}?body=${Uri.encodeComponent(message)}');
      await launchUrl(uri);
    }

    _showSOSDialog(contactsToSend, locationLink);
  }

  Future<void> _callContact(String number) async {
    final Uri phoneUri = Uri.parse('tel:$number');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showAlertDialog('Could not open phone dialer',
          'Failed to launch the call app for $number.');
    }
  }

  void _showSOSDialog(List<EmergencyContact> contacts, String locationLink) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('SOS Alert Sent!',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Text(
                'An emergency alert with your location has been sent to your trusted contacts.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Location Sent:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(locationLink, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              Text(
                'Notified Contacts:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              ...contacts
                  .map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('• ${c.name} (${c.relationship})',
                    style: const TextStyle(fontSize: 14)),
              ))
                  ,
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildLocationInfo(),
              const SizedBox(height: 40),
              _buildSOSButton(),
              const SizedBox(height: 40),
              _buildEmergencyContacts(),
              const SizedBox(height: 100),
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
          Icons.health_and_safety,
          size: 60,
          color: Colors.blue.shade600,
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
          'Press and hold the button below for a quick emergency alert',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentLocationMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade700,
              ),
            ),
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.emergency,
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isPressed ? 'Releasing in 2s' : 'HOLD FOR 2 SECONDS',
                          style: const TextStyle(
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
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Emergency Contacts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: _showAddContactDialog,
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('Add',
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _isLoadingContacts
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: _emergencyContacts
                .map((contact) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildContactItem(contact),
            ))
                .toList(),
          ),
          if (_emergencyContacts.length == 1 && !_isLoadingContacts)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Add family, friends, or doctors to your emergency contacts.',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: contact.isDefault ? Colors.red.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: contact.isDefault ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getRelationshipIcon(contact.relationship),
            size: 24,
            color: contact.isDefault ? Colors.red.shade600 : Colors.blue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${contact.number} (${contact.relationship})',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (contact.isDefault)
                IconButton(
                  onPressed: () => _callContact(contact.number),
                  icon: const Icon(Icons.call, color: Colors.green, size: 22),
                  constraints:
                  const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                  tooltip: 'Call ${contact.name}',
                )
              else ...[
                IconButton(
                  onPressed: () {
                    final locationLink = _currentPosition != null
                        ? 'http://maps.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}'
                        : 'Location unavailable';

                    final message =
                        'EMERGENCY ALERT: I need immediate help. My last known location is: $locationLink';
                    launchUrl(Uri.parse(
                        'sms:${contact.number}?body=${Uri.encodeComponent(message)}'));
                  },
                  icon: const Icon(Icons.send, color: Colors.blue, size: 22),
                  constraints:
                  const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                  tooltip: 'Send SMS to ${contact.name}',
                ),
                IconButton(
                  onPressed: () => _callContact(contact.number),
                  icon: const Icon(Icons.call, color: Colors.green, size: 22),
                  constraints:
                  const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                  tooltip: 'Call ${contact.name}',
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: IconButton(
                    onPressed: () => _deleteContact(contact),
                    icon: const Icon(Icons.delete,
                        color: Colors.red, size: 22),
                    tooltip: 'Delete ${contact.name}',
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getRelationshipIcon(String relationship) {
    switch (relationship) {
      case 'Family':
        return Icons.family_restroom;
      case 'Friend':
        return Icons.person;
      case 'Doctor':
        return Icons.medical_services;
      case 'Hospital':
        return Icons.local_hospital;
      default:
        return Icons.person_outline;
    }
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    String? selectedRelationship = _relationships.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Name',
                    hintText: 'e.g., Mom',
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRelationship,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    prefixIcon: Icon(Icons.group),
                    border: OutlineInputBorder(),
                  ),
                  items: _relationships.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRelationship = newValue;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty &&
                  numberController.text.trim().isNotEmpty) {
                await _addContact(
                  nameController.text.trim(),
                  numberController.text.trim(),
                  selectedRelationship!,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add Contact'),
          ),
        ],
      ),
    );
  }

  Future<void> _addContact(String name, String number, String relationship) async {
    final newContact = EmergencyContact(
      name: name,
      number: number,
      relationship: relationship,
      isDefault: false,
    );

    try {
      final response = await ApiService.post('/emergency/contacts/', newContact.toJson());
      final addedContact = EmergencyContact.fromJson(response);
      setState(() {
        _emergencyContacts.add(addedContact);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name added to emergency contacts'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add contact: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteContact(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text(
            'Are you sure you want to remove ${contact.name} from emergency contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.delete('/emergency/contacts/${contact.id}/');
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
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete contact: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class EmergencyContact {
  final String? id;
  final String name;
  final String number;
  final String relationship;
  final bool isDefault;

  EmergencyContact({
    this.id,
    required this.name,
    required this.number,
    required this.relationship,
    this.isDefault = false,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      relationship: json['relationship'] ?? 'Other',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'relationship': relationship,
      'is_default': isDefault,
    };
  }
}