import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/presentation/pages/otp_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authService = AuthService();

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

  Future<void> _handleSignup() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _fnameFieldState = firstName.isEmpty
          ? InputFieldState.error
          : InputFieldState.defaultState;
      _lnameFieldState = lastName.isEmpty
          ? InputFieldState.error
          : InputFieldState.defaultState;
      _emailFieldState =
          email.isEmpty ? InputFieldState.error : InputFieldState.defaultState;
      _phoneFieldState =
          phone.isEmpty ? InputFieldState.error : InputFieldState.defaultState;
      _passwordFieldState = password.isEmpty
          ? InputFieldState.error
          : InputFieldState.defaultState;
    });

    if ([
      _fnameFieldState,
      _lnameFieldState,
      _emailFieldState,
      _phoneFieldState,
      _passwordFieldState
    ].contains(InputFieldState.error)) {
      return;
    }

    final success = await _authService.registerCustomer(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phoneNumber: phone,
    );

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => OtpPage(
                  email: _emailController.text.trim(),
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  phoneNumber: _phoneController.text.trim(),
                )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register. Try again.')),
      );
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
