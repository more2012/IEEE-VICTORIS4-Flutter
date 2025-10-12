import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../../../services/storage_service.dart';

class AuthService {
  static const String baseUrl = 'https://3awn.up.railway.app';

  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      print('🚀 Login Request: ${json.encode(request.toJson())}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode} - ${response.body}',
        );
      }

      if (response.body.isEmpty) {
        return AuthResponse(
          success: false,
          message: 'Empty response from server',
        );
      }

      Map<String, dynamic> responseJson;
      try {
        responseJson = json.decode(response.body);
      } catch (jsonError) {
        print('❌ JSON Parse Error: $jsonError');
        return AuthResponse(
          success: false,
          message: 'Invalid response format from server',
        );
      }

      final responseData = AuthResponse.fromJson(responseJson);

      if (responseData.success && responseData.tokens != null) {
        await StorageService.setString(
          'auth_token',
          responseData.tokens!.access,
        );
        await StorageService.setString(
          'refresh_token',
          responseData.tokens!.refresh,
        );
        if (responseData.user != null) {
          await StorageService.setString(
            'user_data',
            json.encode(responseData.user!.toJson()),
          );
        }
      }

      return responseData;
    } catch (e) {
      print('❌ Login Error: $e');
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<AuthResponse> signUp(SignUpRequest request) async {
    try {
      print('🚀 SignUp Request: ${json.encode(request.toJson())}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');
      print('📡 Response Headers: ${response.headers}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode} - ${response.body}',
        );
      }

      if (response.body.isEmpty) {
        return AuthResponse(
          success: false,
          message: 'Empty response from server',
        );
      }

      Map<String, dynamic> responseJson;
      try {
        responseJson = json.decode(response.body);
      } catch (jsonError) {
        print('❌ JSON Parse Error: $jsonError');
        return AuthResponse(
          success: false,
          message: 'Invalid response format from server',
        );
      }

      final responseData = AuthResponse.fromJson(responseJson);

      if (responseData.success && responseData.tokens != null) {
        await StorageService.setString(
          'auth_token',
          responseData.tokens!.access,
        );
        await StorageService.setString(
          'refresh_token',
          responseData.tokens!.refresh,
        );
        if (responseData.user != null) {
          await StorageService.setString(
            'user_data',
            json.encode(responseData.user!.toJson()),
          );
        }
      }

      return responseData;
    } catch (e) {
      print('❌ SignUp Error: $e');
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<AuthResponse> forgotPassword(
      ForgotPasswordRequest request,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      return AuthResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<AuthResponse> verifyOTP(OTPVerificationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      return AuthResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<AuthResponse> resetPassword(
      ResetPasswordRequest request,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reset-password/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      return AuthResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  // Logout
  static Future<void> logout() async {
    await StorageService.remove('auth_token');
    await StorageService.remove('refresh_token');
    await StorageService.remove('user_data');
  }

  static Future<bool> isLoggedIn() async {
    final token = StorageService.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getToken() async {
    return StorageService.getString('auth_token');
  }

  static Future<String?> refreshToken() async {
    try {
      final refreshToken = StorageService.getString('refresh_token');
      if (refreshToken == null) {
        print('⚠️ No refresh token available.');
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final newTokens = jsonDecode(response.body);
        final newAccessToken = newTokens['access'];
        await StorageService.setString('auth_token', newAccessToken);
        print('✅ Token refreshed successfully.');
        return newAccessToken;
      } else {
        print('⚠️ Failed to refresh token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Refresh token failed: $e');
      return null;
    }
  }
}