import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _authService = AuthService();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _canResendOtp = true;
  int _resendCountdown = 60;
  
  InputFieldState _otpFieldState = InputFieldState.defaultState;
  InputFieldState _newPasswordFieldState = InputFieldState.defaultState;
  InputFieldState _confirmPasswordFieldState = InputFieldState.defaultState;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _canResendOtp = false;
      _resendCountdown = 60;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        if (_resendCountdown > 0) {
          _startResendCountdown();
        } else {
          setState(() {
            _canResendOtp = true;
          });
        }
      }
    });
  }

  Future<void> _handleResetPassword() async {
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate inputs
    if (otp.isEmpty) {
      setState(() {
        _otpFieldState = InputFieldState.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP code')),
      );
      return;
    }

    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordFieldState = InputFieldState.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a new password')),
      );
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _newPasswordFieldState = InputFieldState.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _confirmPasswordFieldState = InputFieldState.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _otpFieldState = InputFieldState.defaultState;
      _newPasswordFieldState = InputFieldState.defaultState;
      _confirmPasswordFieldState = InputFieldState.defaultState;
    });

    try {
      final success = await _authService.resetPassword(
        email: widget.email,
        otp: otp,
        newPassword: newPassword,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully! You can now login with your new password.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reset password. Please check your OTP and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResendOtp) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.resendForgotPasswordOtp(widget.email);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New OTP sent to your email'),
            backgroundColor: Colors.green,
          ),
        );
        _startResendCountdown();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resend OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: _navigateToLogin,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Enter the code sent to ${widget.email} and your new password.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                
                // OTP input
                InputFieldAtom(
                  placeholder: 'Enter OTP Code',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  state: _otpFieldState,
                  onChanged: (val) {
                    setState(() => _otpFieldState = InputFieldState.defaultState);
                  },
                ),
                const SizedBox(height: 16),
                
                // Resend OTP button
                Center(
                  child: TextButton(
                    onPressed: _canResendOtp && !_isLoading ? _resendOtp : null,
                    child: Text(
                      _canResendOtp 
                        ? 'Resend OTP' 
                        : 'Resend OTP in $_resendCountdown seconds',
                      style: TextStyle(
                        color: _canResendOtp ? Colors.white70 : Colors.white30,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // New password input
                InputFieldAtom(
                  placeholder: 'New Password',
                  controller: _newPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  state: _newPasswordFieldState,
                  showTrailingIcon: true,
                  trailingIcon: _obscureNewPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onTrailingIconTap: _toggleNewPasswordVisibility,
                  onChanged: (val) {
                    setState(() => _newPasswordFieldState = InputFieldState.defaultState);
                  },
                ),
                const SizedBox(height: 16),
                
                // Confirm password input
                InputFieldAtom(
                  placeholder: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  state: _confirmPasswordFieldState,
                  showTrailingIcon: true,
                  trailingIcon: _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onTrailingIconTap: _toggleConfirmPasswordVisibility,
                  onChanged: (val) {
                    setState(() => _confirmPasswordFieldState = InputFieldState.defaultState);
                  },
                ),
                const SizedBox(height: 24),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: _isLoading ? 'Resetting...' : 'Reset Password',
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    onTap: _isLoading ? null : _handleResetPassword,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Back to login
                Center(
                  child: TextButton(
                    onPressed: _navigateToLogin,
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 