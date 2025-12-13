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
  final GlobalKey<OtpInputFieldState> _otpInputKey =
      GlobalKey<OtpInputFieldState>();

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
      status = OtpStatus.initial;
      message = "OTP expired. Please request a new code.";
    });
    // Clear the OTP input fields and focus the first field
    _otpInputKey.currentState?.clearAllFields();
    _startCountdown();
  }

  Future<void> _submitOtp() async {
    String enteredOtp = otpValues.join();
    final success = await _authService.verifyOtp(widget.email, enteredOtp);

    // Check if widget is still mounted before using context
    if (!mounted) return;

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.neutral450,
                      AppColors.neutral450.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    OtpInputField(
                      key: _otpInputKey,
                      status: status,
                      otpValues: otpValues,
                      message: message,
                      onChanged: _onOtpChanged,
                    ),
                    const SizedBox(height: 24),
                    if (status != OtpStatus.expired)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: AppColors.neutral100,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "OTP expires in ${_formatTime(remainingSeconds)}",
                            style: AppTextStyles.textSmRegular.copyWith(
                              color: AppColors.neutral100,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.states['error']!.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.states['error']!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.states['error'],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "OTP expired",
                                  style: AppTextStyles.textSmSemibold.copyWith(
                                    color: AppColors.states['error'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _resendCode,
                            child: Text(
                              "Resend OTP",
                              style: AppTextStyles.textSmMedium.copyWith(
                                color: AppColors.primary200,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    if (_hasInput)
                      CustomButton(
                        label: 'Verify',
                        type: ButtonType.primary,
                        size: ButtonSize.large,
                        customWidth: double.infinity,
                        onTap: _submitOtp,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
