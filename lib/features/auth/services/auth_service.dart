import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../../../services/storage_service.dart';

class AuthService {
  static const String baseUrl =
      'https://qent.up.railway.app/api'; // Replace with your API URL

  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      final responseData = AuthResponse.fromJson(json.decode(response.body));

      if (responseData.success && responseData.token != null) {
        // Store token
        await StorageService.setString('auth_token', responseData.token!);
        await StorageService.setString('user_email', request.email);
      }

      return responseData;
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  // Sign Up
  static Future<AuthResponse> signUp(SignUpRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      return AuthResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  // Forgot Password
  static Future<AuthResponse> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
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
        Uri.parse('$baseUrl/auth/verify-otp'),
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
        Uri.parse('$baseUrl/auth/reset-password'),
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
    await StorageService.remove('user_email');
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
