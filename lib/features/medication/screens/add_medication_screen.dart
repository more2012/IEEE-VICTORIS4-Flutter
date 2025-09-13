import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/medication_controller.dart';
import '../models/medication_model.dart';
import '../../../services/notification_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  String _selectedType = 'Tablet';
  int _timesPerDay = 1;
  int _durationInDays = 7;
  bool _isLoading = false;

  final List<String> _medicineTypes = [
    'Tablet',
    'Capsule',
    'Drop',
    'Injection',
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(screenWidth),
                SizedBox(height: screenHeight * 0.02),
                _buildBasicInfo(screenWidth),
                SizedBox(height: screenHeight * 0.015),
                _buildMedicineType(screenWidth),
                SizedBox(height: screenHeight * 0.015),
                _buildDosage(screenWidth),
                SizedBox(height: screenHeight * 0.015),
                _buildTime(screenWidth),
                SizedBox(height: screenHeight * 0.015),
                _buildFrequency(screenWidth),
                SizedBox(height: screenHeight * 0.015),
                _buildDuration(screenWidth),
                SizedBox(height: screenHeight * 0.03),
                _buildSaveButton(screenWidth),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(screenWidth * 0.075),
            ),
            child: Icon(
              Icons.medication,
              size: screenWidth * 0.08,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          FittedBox(
            child: Text(
              'Add New Medication',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medication Name',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.025),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'e.g., Aspirin',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.03,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter medication name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineType(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medicine Type',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.025),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.01,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedType,
                isExpanded: true,
                items: _medicineTypes.map((String type) {
                  IconData iconData;
                  switch (type) {
                    case 'Tablet':
                      iconData = Icons.medication;
                      break;
                    case 'Capsule':
                      iconData = Icons.medical_services;
                      break;
                    case 'Drop':
                      iconData = Icons.water_drop;
                      break;
                    case 'Injection':
                      iconData = Icons.vaccines;
                      break;
                    default:
                      iconData = Icons.medication;
                  }

                  return DropdownMenuItem<String>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          iconData,
                          color: Colors.blue,
                          size: screenWidth * 0.045,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Flexible(
                          child: Text(
                            type,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: screenWidth * 0.04),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosage(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dosage',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.025),
          TextFormField(
            controller: _dosageController,
            decoration: InputDecoration(
              hintText: 'e.g.,100mg',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.03,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter dosage';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTime(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.025),
          InkWell(
            onTap: _selectTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.035),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.blue,
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      _selectedTime.format(context),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_right, size: screenWidth * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequency(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How many times per day?',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            'You\'ll get $_timesPerDay reminder${_timesPerDay > 1 ? 's' : ''} throughout the day',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          Row(
            children: [
              Text(
                'Times per day: ',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              Text(
                '$_timesPerDay',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.01),
          Slider(
            value: _timesPerDay.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() {
                _timesPerDay = value.round();
              });
            },
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            _getFrequencyDescription(),
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDuration(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Treatment Duration',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            'How many days will you take this medication?',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          Row(
            children: [
              Text(
                'Duration: ',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              Text(
                '$_durationInDays days',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.01),
          Slider(
            value: _durationInDays.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() {
                _durationInDays = value.round();
              });
            },
          ),
          SizedBox(height: screenWidth * 0.01),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: screenWidth * 0.04,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    _getDurationDescription(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      color: Colors.blue.shade700,
                      height: 1.2,
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

  Widget _buildSaveButton(double screenWidth) {
    return SizedBox(
      width: double.infinity,
      height: screenWidth * 0.13,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveMedication,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading ? Colors.grey : Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
          width: screenWidth * 0.05,
          height: screenWidth * 0.05,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Add Medication',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getFrequencyDescription() {
    switch (_timesPerDay) {
      case 1:
        return 'Once daily at ${_selectedTime.format(context)}';
      case 2:
        return 'Twice daily (morning and evening)';
      case 3:
        return 'Three times daily (morning, afternoon, night)';
      case 4:
        return 'Four times daily (every 6 hours)';
      case 5:
        return 'Five times daily (every 4-5 hours)';
      case 6:
        return 'Six times daily (every 4 hours)';
      default:
        return '$_timesPerDay times daily';
    }
  }

  String _getDurationDescription() {
    if (_durationInDays == 1) {
      return 'Single dose medication';
    } else if (_durationInDays <= 3) {
      return 'Short-term treatment ($_durationInDays days)';
    } else if (_durationInDays <= 7) {
      return 'One week treatment course';
    } else if (_durationInDays <= 14) {
      return 'Two-week treatment course';
    } else if (_durationInDays <= 21) {
      return 'Three-week treatment course';
    } else {
      return 'Long-term treatment ($_durationInDays days)';
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  void _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final hasPermission = await NotificationService.requestPermissions();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please enable notifications in settings to receive reminders.'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Open Settings',
                  textColor: Colors.white,
                  onPressed: () {
                    NotificationService.openAppSettings();
                  },
                ),
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final medication = Medication(
          id: 'temp',
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
          type: _selectedType,
          timesPerDay: _timesPerDay,
          durationInDays: _durationInDays,
          startDate: DateTime.now(),
        );

        await context.read<MedicationController>().addMedication(medication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${medication.name} added! You\'ll receive reminders at ${_selectedTime.format(context)} for $_durationInDays days.',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding medication: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}