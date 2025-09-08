class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class SignUpRequest {
  final String name;
  final String email;
  final String password;
  final String? phone;

  SignUpRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'password': password, 'phone': phone};
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class OTPVerificationRequest {
  final String email;
  final String otp;

  OTPVerificationRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }
}

class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp, 'new_password': newPassword};
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'],
    );
  }
}
