import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../../../services/storage_service.dart';

class AuthService {
  static const String baseUrl = 'https://3awn.up.railway.app/api';

  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      print('🚀 Login Request: ${json.encode(request.toJson())}');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
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
        // Store tokens and user data
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

  // Sign Up
  static Future<AuthResponse> signUp(SignUpRequest request) async {
    try {
      print('🚀 SignUp Request: ${json.encode(request.toJson())}');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
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
        // Store tokens and user data
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

  // Forgot Password
  static Future<AuthResponse> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      return AuthResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  // Verify OTP
  static Future<AuthResponse> verifyOTP(OTPVerificationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      return AuthResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  // Reset Password
  static Future<AuthResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password/'),
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

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = StorageService.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  // Get stored token
  static String? getToken() {
    return StorageService.getString('auth_token');
  }
}
