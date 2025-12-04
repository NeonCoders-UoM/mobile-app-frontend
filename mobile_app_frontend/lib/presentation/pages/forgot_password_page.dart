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
import 'package:mobile_app_frontend/presentation/pages/reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  InputFieldState _emailFieldState = InputFieldState.defaultState;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    // Validate email
    if (email.isEmpty) {
      setState(() {
        _emailFieldState = InputFieldState.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailFieldState = InputFieldState.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _emailFieldState = InputFieldState.defaultState;
    });

    try {
      final success = await _authService.forgotPassword(email);

      if (success) {
        // Navigate to reset password page with email
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send reset email. Please try again.'),
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

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
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
                'Forgot Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              const Text(
                'Enter your email address and we\'ll send you a code to reset your password.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              
              // Email input
              InputFieldAtom(
                placeholder: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                state: _emailFieldState,
                onChanged: (val) {
                  setState(() => _emailFieldState = InputFieldState.defaultState);
                },
              ),
              const SizedBox(height: 24),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: _isLoading ? 'Sending...' : 'Send Reset Code',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: _isLoading ? null : _handleForgotPassword,
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
    );
  }
} 