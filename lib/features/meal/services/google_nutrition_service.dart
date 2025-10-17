import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/user_profile.dart';

class GoogleNutritionService {
  static const String _baseUrl = GOOGLE_AI_ENDPOINT;

  // Get personalized meal plan based on user profile with retry logic
  static Future<MealPlan> getPersonalizedMealPlan(UserProfile userProfile) async {
    print('\n=== Starting Nutrition Plan Generation ===');
    print('API Key configured: ${GOOGLE_AI_API_KEY.isNotEmpty}');
    print('API Key (first 10 chars): ${GOOGLE_AI_API_KEY.substring(0, 10)}...');
    
    if (GOOGLE_AI_API_KEY.isEmpty) {
      print('ERROR: API key is empty!');
      throw Exception('Google AI API key not configured');
    }

    const int maxAttempts = 3;
    int attempt = 0;
    Duration delay = const Duration(seconds: 3);

    while (attempt < maxAttempts) {
      attempt++;
      print('\n📍 Attempt $attempt of $maxAttempts');

      try {
        final prompt = _generatePersonalizedPrompt(userProfile);
        print('Prompt generated successfully');
        print('User Profile: Age=${userProfile.age}, Gender=${userProfile.gender}, Weight=${userProfile.weight}kg, Height=${userProfile.height}cm');
        
        final url = '$_baseUrl?key=$GOOGLE_AI_API_KEY';
        print('\nAPI Endpoint: $_baseUrl');
        print('Full URL (without key): $_baseUrl?key=***');
        
        final requestBody = {
          'contents': [{
            'parts': [{
              'text': prompt
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          }
        };
        
        print('\nSending POST request...');
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        ).timeout(API_TIMEOUT);

        print('\nResponse received!');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

        if (response.statusCode == 200) {
          print('\n✓ Success! Parsing response...');
          final data = jsonDecode(response.body);
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          print('Extracted text length: ${text.length} characters');
          return _parseMealPlanResponse(text);
        } else if (response.statusCode == 429 || response.statusCode == 503) {
          // Rate limit or service unavailable - retry with backoff
          print('\n⚠️ Rate limit or service busy (${response.statusCode})');
          if (attempt < maxAttempts) {
            print('Waiting ${delay.inSeconds} seconds before retry...');
            await Future.delayed(delay);
            delay *= 2; // Exponential backoff
            continue;
          } else {
            print('Max retries reached. Please wait a minute and try again.');
            throw Exception('API rate limit exceeded. Please wait a minute and try again.');
          }
        } else {
          print('\n✗ ERROR: Non-200 status code');
          print('Full Response Body: ${response.body}');
          throw Exception('Failed to get meal plan: ${response.statusCode}');
        }
      } catch (e, stackTrace) {
        if (e.toString().contains('rate limit')) {
          rethrow; // Don't retry rate limit errors
        }
        
        print('\n✗ EXCEPTION CAUGHT:');
        print('Error: $e');
        print('Stack Trace: $stackTrace');
        
        if (attempt < maxAttempts) {
          print('Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
          delay *= 2;
        } else {
          throw Exception('Error fetching meal plan after $maxAttempts attempts: $e');
        }
      }
    }

    throw Exception('Failed to get meal plan after $maxAttempts attempts');
  }

  static String _generatePersonalizedPrompt(UserProfile userProfile) {
    final healthConditionsText = userProfile.healthConditions.isEmpty
        ? "No specific health conditions"
        : userProfile.healthConditions.join(", ");

    return """
Create a personalized daily meal plan for a user with the following profile:
- Age: ${userProfile.age}
- Gender: ${userProfile.gender}
- Weight: ${userProfile.weight}kg
- Height: ${userProfile.height}cm
- BMI: ${userProfile.bmi.toStringAsFixed(1)} (${userProfile.bmiCategory})
- Health Conditions: $healthConditionsText

Based on this profile, provide tailored nutrition advice for each meal.

Please respond in this exact JSON format:
{
  "breakfast": {
    "suggestion": "brief meal suggestion",
    "dos": [
      "specific do item 1",
      "specific do item 2", 
      "specific do item 3",
      "specific do item 4"
    ],
    "donts": [
      "specific dont item 1",
      "specific dont item 2",
      "specific dont item 3",
      "specific dont item 4"
    ]
  },
  "lunch": {
    "suggestion": "brief meal suggestion",
    "dos": [
      "specific do item 1",
      "specific do item 2",
      "specific do item 3", 
      "specific do item 4"
    ],
    "donts": [
      "specific dont item 1",
      "specific dont item 2",
      "specific dont item 3",
      "specific dont item 4"
    ]
  },
  "dinner": {
    "suggestion": "brief meal suggestion",
    "dos": [
      "specific do item 1",
      "specific do item 2",
      "specific do item 3",
      "specific do item 4"
    ],
    "donts": [
      "specific dont item 1",
      "specific dont item 2",
      "specific dont item 3", 
      "specific dont item 4"
    ]
  },
  "snacks": {
    "suggestion": "brief snack suggestion",
    "dos": [
      "specific do item 1",
      "specific do item 2",
      "specific do item 3",
      "specific do item 4"
    ],
    "donts": [
      "specific dont item 1",
      "specific dont item 2",
      "specific dont item 3",
      "specific dont item 4"
    ]
  }
}

Make all advice specific to the user's profile, health conditions, and BMI category.
""";
  }

  static MealPlan _parseMealPlanResponse(String response) {
    try {
      print('\n=== Parsing Meal Plan Response ===');
      print('Response length: ${response.length} characters');
      
      // Extract JSON from the response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;

      print('JSON start index: $jsonStart');
      print('JSON end index: $jsonEnd');

      if (jsonStart == -1 || jsonEnd == 0) {
        print('ERROR: Invalid JSON format in response');
        print('Response preview: ${response.substring(0, response.length > 200 ? 200 : response.length)}');
        throw Exception('Invalid response format');
      }

      final jsonString = response.substring(jsonStart, jsonEnd);
      print('Extracted JSON string (first 300 chars): ${jsonString.substring(0, jsonString.length > 300 ? 300 : jsonString.length)}');
      
      final data = jsonDecode(jsonString);
      print('JSON decoded successfully');
      print('Keys found: ${data.keys.toList()}');

      final mealPlan = MealPlan(
        breakfast: MealAdvice.fromJson(data['breakfast']),
        lunch: MealAdvice.fromJson(data['lunch']),
        dinner: MealAdvice.fromJson(data['dinner']),
        snacks: MealAdvice.fromJson(data['snacks']),
      );
      
      print('✓ Meal plan parsed successfully!');
      return mealPlan;
    } catch (e, stackTrace) {
      print('\n✗ PARSING ERROR:');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      throw Exception('Failed to parse meal plan response: $e');
    }
  }
}

class MealPlan {
  final MealAdvice breakfast;
  final MealAdvice lunch;
  final MealAdvice dinner;
  final MealAdvice snacks;

  MealPlan({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
  });
}

class MealAdvice {
  final String suggestion;
  final List<String> dos;
  final List<String> donts;

  MealAdvice({
    required this.suggestion,
    required this.dos,
    required this.donts,
  });

  factory MealAdvice.fromJson(Map<String, dynamic> json) {
    return MealAdvice(
      suggestion: json['suggestion'] ?? '',
      dos: List<String>.from(json['dos'] ?? []),
      donts: List<String>.from(json['donts'] ?? []),
    );
  }
}