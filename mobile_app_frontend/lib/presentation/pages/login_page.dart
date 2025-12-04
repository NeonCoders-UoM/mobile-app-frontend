import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';

import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/pages/register_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/presentation/pages/forgot_password_page.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/core/services/local_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _authService = AuthService();

  InputFieldState _emailFieldState = InputFieldState.defaultState;
  InputFieldState _passwordFieldState = InputFieldState.defaultState;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.loginCustomer(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (result != null) {
      final token = result['token'];
      final customerId = result['customerId'];

      // Save authentication data to local storage
      await LocalStorageService.saveAuthData(
        token: token,
        customerId: customerId,
      );

      print('💾 Authentication data saved after login');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VehicleDetailsHomePage(
            customerId: customerId,
            token: token,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid credentials or email not verified')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
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
                const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  placeholder: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  state: _emailFieldState,
                  onChanged: (val) {
                    setState(
                        () => _emailFieldState = InputFieldState.defaultState);
                  },
                ),
                const SizedBox(height: 20),
                InputFieldAtom(
                  placeholder: 'Password',
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  state: _passwordFieldState,
                  obscureText: _obscurePassword,
                  showTrailingIcon: true,
                  trailingIcon: _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onTrailingIconTap: _togglePasswordVisibility,
                  onChanged: (val) {
                    setState(() =>
                        _passwordFieldState = InputFieldState.defaultState);
                  },
                ),
                const SizedBox(height: 8),
                
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _navigateToForgotPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'By proceeding, you agree to the Terms and Conditions',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Sign in with Email',
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    onTap: _handleLogin,
                  ),
                ),

                

                
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: _navigateToRegister,
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
