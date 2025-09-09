import 'user_model.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class SignUpRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phone;

  SignUpRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'password': password,
      'phone': phone,
    };
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
  final UserModel? user;
  final Tokens? tokens;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Check if response has user and tokens (successful registration)
    final hasUser = json['user'] != null;
    final hasTokens = json['tokens'] != null;
    final hasMessage = json['message'] != null;

    return AuthResponse(
      success: json['success'] ?? (hasUser && hasTokens),
      message:
          json['message'] ??
          (hasMessage ? json['message'] : 'Registration completed'),
      user: hasUser ? UserModel.fromJson(json['user']) : null,
      tokens: hasTokens ? Tokens.fromJson(json['tokens']) : null,
    );
  }
}

class Tokens {
  final String access;
  final String refresh;

  Tokens({required this.access, required this.refresh});

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(access: json['access'] ?? '', refresh: json['refresh'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'access': access, 'refresh': refresh};
  }
}
