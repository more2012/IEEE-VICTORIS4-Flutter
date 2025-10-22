import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration class for accessing API keys and endpoints
/// All sensitive data should be stored in .env file
class EnvConfig {
  /// Primary Google AI API key for nutrition service
  static String get googleAiApiKey => dotenv.env['GOOGLE_AI_API_KEY'] ?? '';
  
  /// Fallback Google AI API key (shared with medication/chatbot)
  static String get googleAiApiKeyFallback => dotenv.env['GOOGLE_AI_API_KEY_FALLBACK'] ?? '';
  
  /// Google AI API endpoint
  static String get googleAiEndpoint => dotenv.env['GOOGLE_AI_ENDPOINT'] ?? 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
  /// Validate that all required environment variables are set
  static bool validateConfig() {
    if (googleAiApiKey.isEmpty) {
      throw Exception('GOOGLE_AI_API_KEY is not set in .env file');
    }
    if (googleAiApiKeyFallback.isEmpty) {
      throw Exception('GOOGLE_AI_API_KEY_FALLBACK is not set in .env file');
    }
    return true;
  }
}
