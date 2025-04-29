import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  InputFieldState _emailFieldState = InputFieldState.defaultState;
  InputFieldState _phoneFieldState = InputFieldState.defaultState;
  InputFieldState _fnameFieldState = InputFieldState.defaultState;
  InputFieldState _lnameFieldState = InputFieldState.defaultState;
  InputFieldState _passwordFieldState = InputFieldState.defaultState;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleSignup() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailFieldState =
          email.isEmpty ? InputFieldState.error : InputFieldState.defaultState;
      _phoneFieldState = RegExp(r'^\+?\d{9,15}$').hasMatch(phone)
          ? InputFieldState.defaultState
          : InputFieldState.error;
      _passwordFieldState = password.isEmpty
          ? InputFieldState.error
          : InputFieldState.defaultState;
    });

    if (_emailFieldState == InputFieldState.defaultState &&
        _phoneFieldState == InputFieldState.defaultState &&
        _passwordFieldState == InputFieldState.defaultState) {
      print('Signing up with email: $email');
    }
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
                    'Create your Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: InputFieldAtom(
                        placeholder: 'First Name',
                        controller: _firstNameController,
                        state: _fnameFieldState,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InputFieldAtom(
                        placeholder: 'Last Name',
                        controller: _lastNameController,
                        state: _lnameFieldState,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                  placeholder: 'Phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  state: _phoneFieldState,
                  onChanged: (val) {
                    setState(
                        () => _phoneFieldState = InputFieldState.defaultState);
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
                    label: 'Sign Up with Email',
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    onTap: _handleSignup,
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
                        "Already have an account? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          'Login Now',
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
