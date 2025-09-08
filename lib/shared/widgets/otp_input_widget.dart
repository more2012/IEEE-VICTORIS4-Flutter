import 'package:flutter/material.dart';
import 'custom_text_field.dart';

class OTPInputWidget extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const OTPInputWidget({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<OTPInputWidget> createState() => OTPInputWidgetState();
}

class OTPInputWidgetState extends State<OTPInputWidget> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.length; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onOTPChanged(int index, String value) {
    if (value.length == 1) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Get current OTP
    final otp = _controllers.map((controller) => controller.text).join();
    widget.onChanged?.call(otp);

    // Check if OTP is complete
    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  String getOTP() {
    return _controllers.map((controller) => controller.text).join();
  }

  void clearOTP() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return CustomOTPField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          onChanged: (value) => _onOTPChanged(index, value),
        );
      }),
    );
  }
}
