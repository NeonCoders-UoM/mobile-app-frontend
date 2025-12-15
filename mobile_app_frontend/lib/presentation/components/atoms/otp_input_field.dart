import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'enums/otp_input_field_state.dart';

class OtpInputField extends StatefulWidget {
  final OtpStatus status;
  final List<String> otpValues;
  final String message;
  final Function(int index, String value) onChanged;

  const OtpInputField({
    super.key,
    required this.status,
    required this.otpValues,
    required this.message,
    required this.onChanged,
  });

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(
      widget.otpValues.length,
      (index) => FocusNode(),
    );
    _controllers = List.generate(
      widget.otpValues.length,
      (index) => TextEditingController(),
    );

    // Auto-focus the first field after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    widget.onChanged(index, value);

    // Auto-focus to next field if a digit is entered
    if (value.isNotEmpty && index < widget.otpValues.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-focus to previous field if digit is deleted and current field is empty
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  // Method to focus the first field (can be called from parent)
  void focusFirstField() {
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  // Method to clear all fields
  void clearAllFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  Color _borderColor() {
    switch (widget.status) {
      case OtpStatus.success:
        return AppColors.states['ok'] ?? Colors.greenAccent;
      case OtpStatus.error:
        return AppColors.states['error'] ?? Colors.redAccent;
      case OtpStatus.initial:
      default:
        return AppColors.neutral200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Enter code",
          style: AppTextStyles.displaySmSemibold
              .copyWith(color: AppColors.neutral100),
        ),
        const SizedBox(height: 8),
        Text(
          "We've sent an SMS with an activation code to your Email",
          style: AppTextStyles.textXsmRegular
              .copyWith(color: AppColors.neutral200),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.otpValues.length, (index) {
            return Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.neutral450.withOpacity(0.5),
                  border: Border.all(
                    color: _borderColor(),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (value) => _onOtpChanged(index, value),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: AppTextStyles.textLgBold
                      .copyWith(color: AppColors.neutral100),
                  decoration: const InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        if (widget.status == OtpStatus.error)
          Text(
            widget.message,
            style: AppTextStyles.textXsmRegular
                .copyWith(color: AppColors.states['error']),
          ),
      ],
    );
  }
}
