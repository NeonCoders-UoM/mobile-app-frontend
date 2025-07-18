// otp_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/otp_input_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/otp_input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/presentation/pages/personaldetails_page.dart';

class OtpPage extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const OtpPage({
    super.key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  List<String> otpValues = List.filled(6, '');
  int remainingSeconds = 600;
  OtpStatus status = OtpStatus.initial;
  String message = "OTP expired. Please request a new code.";
  Timer? _timer;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      remainingSeconds = 600;
      status = OtpStatus.initial;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 1) {
        setState(() {
          remainingSeconds = 0;
          status = OtpStatus.expired;
        });
        timer.cancel();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    setState(() {
      otpValues[index] = value;
    });
  }

  void _resendCode() {
    setState(() {
      otpValues = List.filled(6, '');
    });
    _startCountdown();
  }

  Future<void> _submitOtp() async {
    String enteredOtp = otpValues.join();
    final success = await _authService.verifyOtp(widget.email, enteredOtp);
    if (success) {
      // ✅ Navigate with data to PersonaldetailsPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PersonaldetailsPage(
            firstName: widget.firstName,
            lastName: widget.lastName,
            email: widget.email,
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    } else {
      setState(() {
        status = OtpStatus.error;
        message = "Invalid OTP. Please try again.";
      });
    }
  }

  bool get _hasInput => otpValues.every((e) => e.isNotEmpty);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'OTP Verification',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OtpInputField(
                status: status,
                otpValues: otpValues,
                message: message,
                onChanged: _onOtpChanged,
              ),
              const SizedBox(height: 8),
              if (status != OtpStatus.expired)
                Text(
                  "OTP will expire in ${_formatTime(remainingSeconds)}",
                  style: AppTextStyles.textXsmRegular.copyWith(
                    color: AppColors.neutral300,
                  ),
                )
              else
                Column(
                  children: [
                    Text(
                      "OTP expired",
                      style: AppTextStyles.textXsmBold.copyWith(
                        color: AppColors.states['error'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _resendCode,
                      child: Text(
                        "Resend OTP",
                        style: AppTextStyles.textSmMedium.copyWith(
                          color: AppColors.primary100,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              if (_hasInput)
                SizedBox(
                  width: 320,
                  height: 50,
                  child: CustomButton(
                    label: 'Verify',
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    onTap: _submitOtp,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
