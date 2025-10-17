import 'package:flutter/material.dart';
import '../constants.dart';

class MealCard extends StatelessWidget {
  final MealType mealType;
  final VoidCallback onTap;

  const MealCard({
    Key? key,
    required this.mealType,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: _getGradientColors(mealType),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    mealType.icon,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealType.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMealDescription(mealType),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return [Colors.orange.shade400, Colors.deepOrange.shade600];
      case MealType.lunch:
        return [Colors.blue.shade400, Colors.indigo.shade600];
      case MealType.dinner:
        return [Colors.purple.shade400, Colors.deepPurple.shade600];
      case MealType.snacks:
        return [Colors.green.shade400, Colors.teal.shade600];
    }
  }

  String _getMealDescription(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Start your day right with healthy breakfast tips';
      case MealType.lunch:
        return 'Fuel your afternoon with balanced lunch advice';
      case MealType.dinner:
        return 'End your day with nutritious dinner guidance';
      case MealType.snacks:
        return 'Smart snacking tips for between meals';
    }
  }
}