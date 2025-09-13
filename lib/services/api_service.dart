import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/auth/services/auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://3awn.up.railway.app/api';

  static Future<dynamic> _makeAuthenticatedRequest(
      Future<http.Response> Function(String token) request,
      String? endpoint,
      {int retries = 0}
      ) async {
    final token = await AuthService.getToken();
    final response = await request(token!);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else if (response.statusCode == 401 && retries == 0) {
      print('⚠️ Token expired, attempting to refresh...');
      final newToken = await AuthService.refreshToken();
      if (newToken != null) {
        return _makeAuthenticatedRequest(request, endpoint, retries: 1);
      }
    }

    throw Exception('Failed to post data: ${response.statusCode} - ${response.body}');
  }

  static Future<dynamic> get(String endpoint) async {
    return _makeAuthenticatedRequest((token) {
      return http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
    }, endpoint);
  }

  static Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    return await _makeAuthenticatedRequest((token) {
      return http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(data),
      );
    }, endpoint) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> put(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    return await _makeAuthenticatedRequest((token) {
      return http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(data),
      );
    }, endpoint) as Map<String, dynamic>;
  }

  static Future<void> delete(String endpoint) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete data: ${response.statusCode}');
    }
  }
}