import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alternative_medicine_model.dart';
import '../services/storage_service.dart';

class AlternativeMedicineService {
  static const String _baseUrl = 'https://3awn.up.railway.app/api';

  String? _getAuthToken() {
    try {
      final token = StorageService.getString('auth_token') ??
          StorageService.getString('access_token') ??
          StorageService.getString('user_token');
      return token;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_getAuthToken() != null) 'Authorization': 'Bearer ${_getAuthToken()}',
  };

  Future<int?> searchDrugId(String medicineName) async {
    final encodedMedicineName = Uri.encodeComponent(medicineName);
    final alternativesUrl = '$_baseUrl/drugs/alternatives?name=$encodedMedicineName';

    print('🔎 Searching drug ID: $medicineName via URL: $alternativesUrl');

    final response = await http.get(Uri.parse(alternativesUrl), headers: _headers);
    print('🔸 search Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty) {
        print('Warning: Search returned 200 but body was empty.');
        return null;
      }

      try {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final idCandidate = data[0]['id'];
          // Safely parse the ID, handling both int and string representations
          final drugId = idCandidate is int ? idCandidate : int.tryParse(idCandidate.toString());

          if (drugId != null) {
            print('🔍 Found Drug ID: $drugId for $medicineName');
            return drugId;
          }
        } else {
          print('🔍 Search returned no results for $medicineName.');
        }
      } catch (e) {
        print('Error decoding successful search response: $e');
      }
    } else {
      print('Error: Search failed with status code ${response.statusCode}. Body: ${response.body}');
    }
    return null;
  }

  Future<List<AlternativeMedicine>> getAlternativesByMedicineName(String medicineName) async {
    // URL-encode the medicine name to handle spaces/special characters safely
    final encodedMedicineName = Uri.encodeComponent(medicineName);
    final alternativesUrl = '$_baseUrl/drugs/alternatives?name=$encodedMedicineName';

    print('🔍 Fetching alternatives from: $alternativesUrl');

    try {
      final response = await http.get(Uri.parse(alternativesUrl), headers: _headers);

      print('🔸 Alternatives Response Status: ${response.statusCode}');
      print('🔸 Alternatives Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Check for empty body before decoding
        if (response.body.trim().isEmpty) {
          print('Warning: Alternatives returned 200 but body was empty.');
          return [];
        }

        final data = jsonDecode(response.body);
        if (data is List) {
          print('✅ Successfully fetched ${data.length} alternatives.');
          return data.map((json) => AlternativeMedicine.fromJson(json)).toList();
        } else {
          print('⚠️ Alternatives endpoint returned non-list data: $data');
        }
      } else {
        print('❌ Error fetching alternatives (Status ${response.statusCode}): ${response.body}');
      }
      return [];
    } catch (e) {
      print('❌ Error fetching alternatives: $e');
      return [];
    }
  }

  /// Updated method to use the correct API call
  Future<List<AlternativeMedicine>> findAlternatives(String medicineName) async {
    print('🚀 Starting search for alternatives for: $medicineName');

    try {
      // Directly call the alternatives endpoint with medicine name
      return await getAlternativesByMedicineName(medicineName);
    } catch (e) {
      print('❌ Error in findAlternatives: $e');
      return [];
    }
  }

  Future<List<AlternativeMedicine>> getHerbalAlternatives(String medicineName) async {
    final encodedMedicineName = Uri.encodeComponent(medicineName);
    // Try the correct endpoint - it might be /drugs/herbal-alternatives or similar
    final herbsUrl = '$_baseUrl/drugs/alternatives/herbs?name=$encodedMedicineName';

    print('🌿 Fetching herbal alternatives from: $herbsUrl');

    try {
      final response = await http.get(Uri.parse(herbsUrl), headers: _headers);

      print('🔸 Herbs Response Status: ${response.statusCode}');
      print('🔸 Herbs Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          print('Warning: Herbs returned 200 but body was empty.');
          return [];
        }

        final data = jsonDecode(response.body);
        
        // Handle the response structure: {"drug": "...", "herbal_alternatives": [...]}
        if (data is Map<String, dynamic> && data.containsKey('herbal_alternatives')) {
          final herbsList = data['herbal_alternatives'] as List;
          print('✅ Successfully fetched ${herbsList.length} herbal alternatives.');
          
          // Convert string list to AlternativeMedicine objects
          return herbsList.map((herbName) {
            return AlternativeMedicine(
              id: herbName.toString(),
              name: herbName.toString(),
              activeIngredient: 'Herbal',
              dosage: 'As directed',
              manufacturer: 'Natural',
              price: 0.0,
              description: 'Herbal alternative',
              similarityPercentage: 0.0,
              sideEffects: [],
              availability: 'Available',
              imageUrl: '',
            );
          }).toList();
        } else if (data is List) {
          // Fallback if it returns a list directly
          print('✅ Successfully fetched ${data.length} herbal alternatives.');
          return data.map((json) => AlternativeMedicine.fromJson(json)).toList();
        } else {
          print('⚠️ Herbs endpoint returned unexpected data structure: $data');
        }
      } else {
        print('❌ Error fetching herbal alternatives (Status ${response.statusCode}): ${response.body}');
      }
      return [];
    } catch (e) {
      print('❌ Error fetching herbal alternatives: $e');
      return [];
    }
  }

  /// Keep the old method for backward compatibility (if needed elsewhere)
  Future<List<AlternativeMedicine>> getAlternativesByDrugId(int id) async {
    print('⚠️ getAlternativesByDrugId is deprecated. Use getAlternativesByMedicineName instead.');
    return [];
  }
}