import 'package:awan/features/medication/models/medication_model.dart';
import 'package:awan/features/medication/screens/medication_detail_screen.dart';
import 'package:flutter/material.dart';

class MedicationReminderCard extends StatelessWidget {
  final String medicationName;
  final String time;
  final String? doseDescription;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final Medication? medication;
  final DateTime? selectedDate;
  final int? doseNumber;
  final bool isInMedicationScreen;

  const MedicationReminderCard({
    super.key,
    required this.medicationName,
    required this.time,
    this.doseDescription,
    required this.isCompleted,
    this.onTap,
    this.onComplete,
    this.medication,
    this.selectedDate,
    this.doseNumber,
    this.isInMedicationScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isCompletelyFinished = medication?.isCompletelyFinished ?? false;

    final dateSpecificTaken = selectedDate != null && medication != null && doseNumber != null
        ? medication!.isDoseTakenForDate(selectedDate!, doseNumber!)
        : isCompleted;

    return GestureDetector(
      onTap: () {
        if (medication != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicationDetailScreen(medication: medication!),
            ),
          );
        } else if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompletelyFinished
                ? Colors.green.withOpacity(0.5)
                : dateSpecificTaken
                ? Colors.blue.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: isCompletelyFinished
                    ? Colors.green.withOpacity(0.1)
                    : dateSpecificTaken
                    ? Colors.blue.withOpacity(0.1)
                    : _getMedicationTypeColor(medication?.type ?? 'Tablet').withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCompletelyFinished
                    ? Icons.check_circle
                    : dateSpecificTaken
                    ? Icons.check_circle_outline
                    : _getMedicationTypeIcon(medication?.type ?? 'Tablet'),
                color: isCompletelyFinished
                    ? Colors.green
                    : dateSpecificTaken
                    ? Colors.blue
                    : _getMedicationTypeColor(medication?.type ?? 'Tablet'),
                size: screenWidth * 0.06,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicationName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      decoration: isCompletelyFinished
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Row(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (doseDescription != null && doseDescription!.isNotEmpty) ...[
                        Text(
                          ' • $doseDescription',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.blue.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (medication != null && medication!.durationInDays > 1) ...[
                    SizedBox(height: screenWidth * 0.02),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: medication!.completionPercentage,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompletelyFinished ? Colors.green : Colors.blue,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          '${medication!.daysCompleted}/${medication!.durationInDays} days',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.02),

            // ✅ FIXED: Working button with proper functionality and non-clickable state in medication screen
            if (!isCompletelyFinished)
              GestureDetector(
                onTap: isInMedicationScreen ? null : onComplete,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenWidth * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: dateSpecificTaken
                        ? Colors.green
                        : isInMedicationScreen ? Colors.grey.shade400 : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getButtonText(dateSpecificTaken),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: screenWidth * 0.035,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      'Finished',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: Proper button text logic
  String _getButtonText(bool dateSpecificTaken) {
    if (dateSpecificTaken) {
      return 'Taken';
    }
    return isInMedicationScreen ? 'In Progress' : 'Take';
  }

  IconData _getMedicationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return Icons.medication;
      case 'capsule':
        return Icons.medical_services;
      case 'drop':
        return Icons.water_drop;
      case 'injection':
        return Icons.vaccines;
      case 'syrup':
        return Icons.local_drink;
      case 'inhaler':
        return Icons.air;
      default:
        return Icons.medication;
    }
  }

  Color _getMedicationTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return Colors.blue;
      case 'capsule':
        return Colors.green;
      case 'drop':
        return Colors.cyan;
      case 'injection':
        return Colors.red;
      case 'syrup':
        return Colors.orange;
      case 'inhaler':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}