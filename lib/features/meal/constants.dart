// Meal Feature Constants
// Google AI Studio API Configuration

// Primary API key for nutrition service (has separate quota)
const String GOOGLE_AI_API_KEY = "AIzaSyBgvE3mzni6IOGomkoexACyzqwyUAkgoY8";
// Fallback API key (shared with medication/chatbot - use if primary fails)
const String GOOGLE_AI_API_KEY_FALLBACK = "AIzaSyCiesWCBdEle03bZG7Vf491t2KgiYyKCnY";
const String GOOGLE_AI_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

const Duration API_TIMEOUT = Duration(seconds: 30);
enum MealType {
  breakfast,
  lunch,
  dinner,
  snacks,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snacks:
        return 'Snacks';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snacks:
        return '🍿';
    }
  }
}