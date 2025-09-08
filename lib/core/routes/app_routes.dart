import 'package:flutter/material.dart';
import '../../features/screens/on_boarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../screens/homepage.dart';
import '../constants/app_constants.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    AppConstants.onboardingRoute: (_) => const OnBoardingScreen(),
    AppConstants.homeRoute: (_) => const Homepage(),
    AppConstants.loginRoute: (_) => const LoginScreen(),
    AppConstants.signupRoute: (_) => const SignUpScreen(),
    AppConstants.forgotPasswordRoute: (_) => const ForgotPasswordScreen(),
    AppConstants.otpVerificationRoute: (_) => const OTPVerificationScreen(),
    AppConstants.resetPasswordRoute: (_) => const ResetPasswordScreen(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.onboardingRoute:
        return MaterialPageRoute(
          builder: (_) => const OnBoardingScreen(),
          settings: settings,
        );
      case AppConstants.homeRoute:
        return MaterialPageRoute(
          builder: (_) => const Homepage(),
          settings: settings,
        );
      case AppConstants.loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case AppConstants.signupRoute:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
      case AppConstants.forgotPasswordRoute:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case AppConstants.otpVerificationRoute:
        return MaterialPageRoute(
          builder: (_) => const OTPVerificationScreen(),
          settings: settings,
        );
      case AppConstants.resetPasswordRoute:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const OnBoardingScreen(),
          settings: settings,
        );
    }
  }
}
