// Meal Feature Constants
import '../../core/config/env_config.dart';

// Google AI Studio API Configuration
// API keys are now loaded from .env file for security
String get GOOGLE_AI_API_KEY => EnvConfig.googleAiApiKey;
String get GOOGLE_AI_API_KEY_FALLBACK => EnvConfig.googleAiApiKeyFallback;
String get GOOGLE_AI_ENDPOINT => EnvConfig.googleAiEndpoint;

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