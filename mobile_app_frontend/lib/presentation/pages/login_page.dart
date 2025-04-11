import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  InputFieldState _emailFieldState = InputFieldState.defaultState;
  InputFieldState _passwordFieldState = InputFieldState.defaultState;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _emailFieldState = email.isEmpty
            ? InputFieldState.error
            : InputFieldState.defaultState;
        _passwordFieldState = password.isEmpty
            ? InputFieldState.error
            : InputFieldState.defaultState;
      });
      return;
    }

    print('Logging in with email: $email and password: $password');
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
                const Center(
                  child: Text(
                    'Or Signup with',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.white54),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Google sign in
                        },
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Google'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.white54),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Apple sign in
                        },
                        icon: const Icon(Icons.apple, size: 28),
                        label: const Text('Apple'),
                      ),
                    ),
                  ],
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
                        onTap: () {
                          // Navigate to Signup Page
                        },
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
