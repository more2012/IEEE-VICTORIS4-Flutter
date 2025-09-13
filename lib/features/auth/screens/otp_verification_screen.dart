import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/otp_input_widget.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<OTPInputWidgetState> _otpKey =
      GlobalKey<OTPInputWidgetState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['email'] != null) {
        context.read<AuthController>().emailController.text = args['email'];
      }
    });
  }

  String _getOTPCode() {
    return _otpKey.currentState?.getOTP() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon
                const Icon(Icons.verified_user, size: 80, color: Colors.blue),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Consumer<AuthController>(
                  builder: (context, controller, child) {
                    return Text(
                      'We\'ve sent a 6-digit code to\n${controller.emailController.text}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 40),

                // OTP Input Fields
                OTPInputWidget(
                  key: _otpKey,
                  length: 6,
                  onCompleted: (otp) {
                    // Auto-verify when OTP is complete
                    context.read<AuthController>().otpController.text = otp;
                  },
                ),
                const SizedBox(height: 32),

                // Verify Button
                Consumer<AuthController>(
                  builder: (context, controller, child) {
                    return ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              final otpCode = _getOTPCode();
                              if (otpCode.length == 6) {
                                controller.otpController.text = otpCode;
                                final success = await controller.verifyOTP();
                                if (success && mounted) {
                                  Navigator.pushNamed(
                                    context,
                                    '/reset-password',
                                    arguments: {
                                      'email': controller.emailController.text
                                          .trim(),
                                      'otp': otpCode,
                                    },
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter the complete OTP code',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive the code? "),
                    TextButton(
                      onPressed: () async {
                        final controller = context.read<AuthController>();
                        await controller.forgotPassword();
                      },
                      child: const Text('Resend OTP'),
                    ),
                  ],
                ),

                // Back to Forgot Password
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back to Forgot Password'),
                ),

                // Error/Success Messages
                Consumer<AuthController>(
                  builder: (context, controller, child) {
                    if (controller.errorMessage != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          controller.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    if (controller.successMessage != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          controller.successMessage!,
                          style: TextStyle(color: Colors.green.shade700),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
