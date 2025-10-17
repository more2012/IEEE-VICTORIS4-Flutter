import 'package:awan/features/meal/models/user_profile.dart';

import '../constants.dart';
import 'google_nutrition_service.dart';

class LocalFallbackProvider {
  static NutritionAdvice getFallbackAdvice(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return NutritionAdvice(
          dos: [
            'Start with protein-rich foods like eggs or Greek yogurt',
            'Include whole grains like oatmeal or whole wheat toast',
            'Add fresh fruits for vitamins and fiber',
            'Stay hydrated with water or herbal tea',
            'Keep portions moderate to maintain energy levels'
          ],
          donts: [
            'Skip breakfast entirely',
            'Rely on sugary cereals or pastries',
            'Drink too much caffeine on an empty stomach',
            'Eat heavy, greasy foods early morning',
            'Rush through your meal without chewing properly'
          ],
        );
      case MealType.lunch:
        return NutritionAdvice(
          dos: [
            'Include a balance of protein, carbs, and vegetables',
            'Choose lean proteins like chicken, fish, or legumes',
            'Add colorful vegetables for nutrients',
            'Stay hydrated with water throughout the meal',
            'Take time to eat mindfully and chew slowly'
          ],
          donts: [
            'Skip lunch due to busy schedule',
            'Eat only fast food or processed meals',
            'Consume excessive portions that cause afternoon sluggishness',
            'Drink sugary beverages with your meal',
            'Eat while distracted by screens or work'
          ],
        );
      case MealType.dinner:
        return NutritionAdvice(
          dos: [
            'Keep dinner lighter than lunch',
            'Include plenty of vegetables and lean protein',
            'Choose complex carbohydrates in moderation',
            'Finish eating 2-3 hours before bedtime',
            'Create a relaxing mealtime atmosphere'
          ],
          donts: [
            'Eat heavy, rich foods close to bedtime',
            'Skip dinner entirely to lose weight',
            'Consume excessive alcohol with dinner',
            'Eat large portions that disrupt sleep',
            'Rush through dinner without enjoying it'
          ],
        );
      case MealType.snacks:
        return NutritionAdvice(
          dos: [
            'Choose nutrient-dense snacks like nuts or fruits',
            'Keep portions small and controlled',
            'Combine protein with healthy carbs',
            'Time snacks between meals appropriately',
            'Stay hydrated while snacking'
          ],
          donts: [
            'Reach for processed, high-sugar snacks',
            'Eat mindlessly while watching TV or working',
            'Skip snacks if you\'re genuinely hungry between meals',
            'Choose snacks high in trans fats or artificial ingredients',
            'Eat snacks too close to main meals'
          ],
        );
    }
  }
}