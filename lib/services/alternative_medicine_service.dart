import 'dart:convert';
import 'dart:io';
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

  /// FIX: The original endpoint '/drugs/search' likely resulted in a 404.
  /// Changed to '/drugs' which is the standard REST pattern for filtering.
  Future<int?> searchDrugId(String medicineName) async {
    // URL-encode the medicine name to handle spaces/special characters safely
    final encodedMedicineName = Uri.encodeComponent(medicineName);
    final searchUrl = '$_baseUrl/drugs?q=$encodedMedicineName';

    print('🔎 Searching drug ID: $medicineName via URL: $searchUrl');

    final response = await http.get(Uri.parse(searchUrl), headers: _headers);
    print('🔸 search Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      // Check for empty body before decoding
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


  /// جلب البدائل بالـ ID الصحيح
  Future<List<AlternativeMedicine>> getAlternativesByDrugId(int id) async {
    final alternativesUrl = '$_baseUrl/drugs/alternatives';
    print('Fetching alternatives from: $alternativesUrl');
    try {
      final response = await http.get(Uri.parse(alternativesUrl), headers: _headers);

      if (response.statusCode == 200) {
        print('Alternatives Response Body (for drug ID $id): ${response.body}');
        // ---------------------------------

        final data = jsonDecode(response.body);
        if (data is List) {
          print('Successfully fetched ${data.length} alternatives.');
          return data.map<AlternativeMedicine>((json) => AlternativeMedicine.fromJson(json)).toList();
        } else {
          print('Alternatives endpoint returned non-list data.');
        }
      } else {
        print('Error fetching alternatives (Status ${response.statusCode}): ${response.body}');
      }
      return [];
    } catch (e) {
      print('Error fetching alternatives: $e');
      return [];
    }
  }

  Future<List<AlternativeMedicine>> findAlternatives(String medicineName) async {
    print('Starting search for alternatives for: $medicineName');
    try {
      final drugId = await searchDrugId(medicineName);
      if (drugId == null) {
        print('❌ Could not find Drug ID for $medicineName.');
        return [];
      }
      return await getAlternativesByDrugId(drugId);
    } catch (e) {
      print('Error in findAlternatives: $e');
      return [];
    }
  }
}