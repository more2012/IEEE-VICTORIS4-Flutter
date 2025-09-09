import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';
import '../../../core/utils/validators.dart';
import '../../../services/storage_service.dart';
import 'dart:convert';

class AuthController with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage; // ✅ ADDED: Missing success message
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoggedIn = false;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController(); // ✅ ADDED: Missing controller

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage; // ✅ ADDED: Missing getter
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoggedIn => _isLoggedIn;

  // Form validation
  String? validateEmail(String? value) => Validators.validateEmail(value);
  String? validatePassword(String? value) => Validators.validatePassword(value);
  String? validateFullName(String? value) =>
      Validators.validateRequired(value, 'Full Name');

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 10) {
        return 'Phone number must be at least 10 digits';
      }
    }
    return null;
  }

  String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter OTP';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return validatePassword(value);
  }

  // ✅ ADDED: Missing validation method
  String? validateConfirmNewPassword(String? value) {
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return validatePassword(value);
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ ADDED: Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // ✅ ADDED: Clear all messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Initialize auth state on app start
  Future<void> initializeAuth() async {
    try {
      print('🔄 Initializing auth state...');

      // Check if user data exists in storage
      final userDataString = StorageService.getString('user_data');
      final isLoggedInStored = StorageService.getBool('is_logged_in') ?? false;

      if (userDataString != null && userDataString.isNotEmpty && isLoggedInStored) {
        // User data exists and is logged in
        _isLoggedIn = true;
        print('✅ User is already logged in');
      } else {
        // No user data or not logged in
        _isLoggedIn = false;
        print('❌ User is not logged in');
      }

      notifyListeners();
    } catch (e) {
      print('⚠️ Error initializing auth: $e');
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  // Login method
  Future<bool> login() async {
    if (!_validateLoginForm()) return false;

    _setLoading(true);
    _clearMessages();

    try {
      final request = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final response = await AuthService.login(request);

      if (response.success) {
        // Save login state and user data
        await _saveLoginState(response);

        _setSuccess('Login successful! Welcome back.');
        _setLoading(false);
        clearControllers();
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Sign up method
  Future<bool> signUp() async {
    if (!_validateSignUpForm()) return false;

    _setLoading(true);
    _clearMessages();

    try {
      final request = SignUpRequest(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
      );

      final response = await AuthService.signUp(request);

      if (response.success) {
        // Save login state and user data
        await _saveLoginState(response);

        _setSuccess('Account created successfully! Welcome to Awan.');
        _setLoading(false);
        clearControllers();
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Sign up failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Forgot password method
  Future<bool> forgotPassword() async {
    if (!_validateEmail()) return false;

    _setLoading(true);
    _clearMessages();

    try {
      final request = ForgotPasswordRequest(email: emailController.text.trim());
      final response = await AuthService.forgotPassword(request);

      if (response.success) {
        _setSuccess('Password reset code sent to your email.');
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to send reset email: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP method
  Future<bool> verifyOTP() async {
    if (!_validateOTPForm()) return false;

    _setLoading(true);
    _clearMessages();

    try {
      final request = OTPVerificationRequest(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
      );

      final response = await AuthService.verifyOTP(request);

      if (response.success) {
        _setSuccess('OTP verified successfully!');
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('OTP verification failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Reset password method
  Future<bool> resetPassword() async {
    if (!_validateResetPasswordForm()) return false;

    _setLoading(true);
    _clearMessages();

    try {
      final request = ResetPasswordRequest(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
        newPassword: newPasswordController.text,
      );

      final response = await AuthService.resetPassword(request);

      if (response.success) {
        _setSuccess('Password reset successfully! You can now login with your new password.');
        _setLoading(false);
        clearControllers();
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Save login state to SharedPreferences
  Future<void> _saveLoginState(AuthResponse response) async {
    try {
      // Save login flag
      await StorageService.setBool('is_logged_in', true);

      // Save user data
      if (response.user != null) {
        final userDataJson = json.encode(response.user!.toJson());
        await StorageService.setString('user_data', userDataJson);
        print('✅ User data saved to storage');
      }

      // Save tokens if available
      if (response.tokens != null) {
        await StorageService.setString('access_token', response.tokens!.access);
        await StorageService.setString('refresh_token', response.tokens!.refresh);
        print('✅ Tokens saved to storage');
      }

      _isLoggedIn = true;
      print('✅ Login state saved successfully');

    } catch (e) {
      print('⚠️ Error saving login state: $e');
    }
  }

  // Logout and clear all data
  Future<void> logout() async {
    try {
      // Clear all stored data
      await StorageService.remove('is_logged_in');
      await StorageService.remove('user_data');
      await StorageService.remove('access_token');
      await StorageService.remove('refresh_token');

      // Reset state
      _isLoggedIn = false;
      _errorMessage = null;
      _successMessage = null;

      // Clear all controllers
      clearControllers();

      print('✅ User logged out successfully');
      notifyListeners();
    } catch (e) {
      print('⚠️ Error during logout: $e');
    }
  }

  // Get current user data
  Map<String, dynamic>? getCurrentUserData() {
    try {
      final userDataString = StorageService.getString('user_data');
      if (userDataString != null && userDataString.isNotEmpty) {
        return json.decode(userDataString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('⚠️ Error getting user data: $e');
    }
    return null;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _successMessage = null; // Clear success when showing error
    notifyListeners();
  }

  // ✅ ADDED: Set success message
  void _setSuccess(String success) {
    _successMessage = success;
    _errorMessage = null; // Clear error when showing success
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  bool _validateLoginForm() {
    return validateEmail(emailController.text) == null &&
        validatePassword(passwordController.text) == null;
  }

  bool _validateSignUpForm() {
    return validateFullName(fullNameController.text) == null &&
        validateEmail(emailController.text) == null &&
        validatePassword(passwordController.text) == null;
  }

  bool _validateEmail() {
    return validateEmail(emailController.text) == null;
  }

  bool _validateOTPForm() {
    return validateEmail(emailController.text) == null &&
        validateOTP(otpController.text) == null;
  }

  bool _validateResetPasswordForm() {
    return validateEmail(emailController.text) == null &&
        validateOTP(otpController.text) == null &&
        validatePassword(newPasswordController.text) == null &&
        validateConfirmNewPassword(confirmNewPasswordController.text) == null;
  }

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    phoneController.clear();
    otpController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    confirmNewPasswordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }
}
