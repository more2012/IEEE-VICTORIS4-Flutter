import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../../../core/utils/validators.dart';

class AuthController with ChangeNotifier {
  // Loading states
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  String? _successMessage;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Form validation
  String? validateEmail(String? value) => Validators.validateEmail(value);
  String? validatePassword(String? value) => Validators.validatePassword(value);
  String? validateName(String? value) =>
      Validators.validateRequired(value, 'Name');
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
      return 'OTP is required';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateConfirmNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Set success message
  void _setSuccess(String? success) {
    _successMessage = success;
    notifyListeners();
  }

  // Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Login
  Future<bool> login() async {
    _setLoading(true);
    _setError(null);

    try {
      final request = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final response = await AuthService.login(request);

      if (response.success) {
        _isLoggedIn = true;
        _setSuccess('Login successful!');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Up
  Future<bool> signUp() async {
    _setLoading(true);
    _setError(null);

    try {
      final request = SignUpRequest(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
      );

      final response = await AuthService.signUp(request);

      if (response.success) {
        _setSuccess('Account created successfully!');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Forgot Password
  Future<bool> forgotPassword() async {
    _setLoading(true);
    _setError(null);

    try {
      final request = ForgotPasswordRequest(email: emailController.text.trim());

      final response = await AuthService.forgotPassword(request);

      if (response.success) {
        _setSuccess('OTP sent to your email!');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<bool> verifyOTP() async {
    _setLoading(true);
    _setError(null);

    try {
      final request = OTPVerificationRequest(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
      );

      final response = await AuthService.verifyOTP(request);

      if (response.success) {
        _setSuccess('OTP verified successfully!');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset Password
  Future<bool> resetPassword() async {
    _setLoading(true);
    _setError(null);

    try {
      final request = ResetPasswordRequest(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
        newPassword: newPasswordController.text,
      );

      final response = await AuthService.resetPassword(request);

      if (response.success) {
        _setSuccess('Password reset successfully!');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _isLoggedIn = false;
    clearControllers();
    notifyListeners();
  }

  // Clear all controllers
  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    phoneController.clear();
    otpController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
