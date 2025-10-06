import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/alternative_medicine_model.dart';

class AlternativeMedicineService {
  // Replace with your actual backend URL
  static const String _baseUrl = 'https://3awn.up.railway.app/api';
  static const String _alternativesEndpoint = '/alternatives';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add authentication headers if needed
    // 'Authorization': 'Bearer ${AuthService.getToken()}',
  };

  /// Fetches alternative medicines from the backend
  Future<List<AlternativeMedicine>> getAlternatives({
    required String medicineName,
    String? dosage,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'medicine_name': medicineName,
        if (dosage != null && dosage.isNotEmpty) 'dosage': dosage,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_alternativesEndpoint'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> alternativesJson = data['alternatives'] ?? [];

        return alternativesJson
            .map((json) => AlternativeMedicine.fromJson(json))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to fetch alternatives: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      throw Exception('Error fetching alternatives: $e');
    }
  }

  /// Mock data for testing - USE THIS FOR TESTING FIRST
  Future<List<AlternativeMedicine>> getMockAlternatives(String medicineName) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock alternatives based on common medicines
    final Map<String, List<Map<String, dynamic>>> mockData = {
      'panadol': [
        {
          'id': '1',
          'name': 'Tylenol',
          'active_ingredient': 'Acetaminophen',
          'dosage': '500mg',
          'manufacturer': 'Johnson & Johnson',
          'price': 45.0,
          'description': 'Pain reliever and fever reducer',
          'similarity_percentage': 95.0,
          'side_effects': ['Nausea', 'Stomach pain'],
          'availability': 'Available',
          'image_url': '',
        },
        {
          'id': '2',
          'name': 'Advil',
          'active_ingredient': 'Ibuprofen',
          'dosage': '400mg',
          'manufacturer': 'Pfizer',
          'price': 52.0,
          'description': 'Anti-inflammatory pain reliever',
          'similarity_percentage': 80.0,
          'side_effects': ['Heartburn', 'Dizziness'],
          'availability': 'Available',
          'image_url': '',
        },
      ],
      'aspirin': [
        {
          'id': '3',
          'name': 'Disprin',
          'active_ingredient': 'Acetylsalicylic acid',
          'dosage': '325mg',
          'manufacturer': 'Reckitt Benckiser',
          'price': 38.0,
          'description': 'Pain reliever and blood thinner',
          'similarity_percentage': 92.0,
          'side_effects': ['Stomach irritation', 'Bleeding'],
          'availability': 'Available',
          'image_url': '',
        },
      ],
    };

    final alternatives = mockData[medicineName.toLowerCase()] ?? [];
    return alternatives.map((json) => AlternativeMedicine.fromJson(json)).toList();
  }
}