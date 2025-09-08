import 'package:flutter/material.dart';

class MedicalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;
  final VoidCallback? onTap;

  const MedicalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.04),
        constraints: BoxConstraints(
          minHeight: screenHeight * 0.15, // Minimum height
        ),
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
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: screenWidth * 0.06,
                    color: color,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.more_horiz,
                  color: Colors.grey.shade400,
                  size: screenWidth * 0.05,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: screenHeight * 0.005),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Padding(
                    padding: EdgeInsets.only(bottom: screenWidth * 0.01),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey.shade600,
                      ),
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
}
