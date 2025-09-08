import 'package:awan/features/medication/models/medication_model.dart';
import 'package:awan/features/medication/screens/medication_detail_screen.dart';
import 'package:flutter/material.dart';

class MedicationReminderCard extends StatelessWidget {
  final String medicationName;
  final String time;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final Medication? medication; // Add this parameter

  const MedicationReminderCard({
    super.key,
    required this.medicationName,
    required this.time,
    required this.isCompleted,
    this.onTap,
    this.onComplete,
    this.medication, // Add this
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            color: isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.blue.withOpacity(0.3),
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
                color: (isCompleted ? Colors.green : Colors.blue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.medication,
                color: isCompleted ? Colors.green : Colors.blue,
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
                      decoration: isCompleted
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• Tap for details',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.blue.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            if (!isCompleted)
              GestureDetector(
                onTap: onComplete,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenWidth * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Take',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: screenWidth * 0.05,
              ),
          ],
        ),
      ),
    );
  }
}
