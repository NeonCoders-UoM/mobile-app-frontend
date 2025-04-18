import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'enums/otp_input_field_state.dart';

class OtpInputField extends StatelessWidget {
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

  Color _borderColor() {
    switch (status) {
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
          style: AppTextStyles.displaySmSemibold.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          "We've sent an SMS with an activation code to your phone +9470568620",
          style: AppTextStyles.textXsmRegular
              .copyWith(color: AppColors.neutral150),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(otpValues.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: _borderColor(), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: TextField(
                onChanged: (value) => onChanged(index, value),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: AppTextStyles.textLgBold.copyWith(color: Colors.white),
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        if (status == OtpStatus.error)
          Text(
            message,
            style: AppTextStyles.textXsmRegular
                .copyWith(color: AppColors.states['error']),
          ),
      ],
    );
  }
}
