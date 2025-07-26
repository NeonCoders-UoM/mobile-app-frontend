import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'dart:convert'; // Added for jsonEncode
import 'package:http/http.dart' as http; // Added for http
import 'package:mobile_app_frontend/presentation/pages/password_changed_page.dart';

class ChangePasswordPage extends StatefulWidget {
  final int customerId;
  final String token;
  const ChangePasswordPage(
      {super.key, required this.customerId, required this.token});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypeNewPasswordController =
      TextEditingController();
  InputFieldState _currentPasswordFieldState = InputFieldState.defaultState;
  InputFieldState _newPasswordFieldState = InputFieldState.defaultState;
  InputFieldState _retypeNewPasswordFieldState = InputFieldState.defaultState;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _retypeNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: CustomAppBar(title: 'Change password'),
      body: Center(
        child: SizedBox(
          width: 360,
          child: Column(
            children: [
              SizedBox(
                height: 16,
              ),
              Text(
                'Your password must be at least 6 characters and should include a combination of numbers, letters and special characters (!\$@%)',
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.neutral150,
                ),
              ),
              SizedBox(
                height: 32,
              ),
              InputFieldAtom(
                  controller: _currentPasswordController,
                  state: _currentPasswordFieldState,
                  obscureText: true,
                  placeholder: 'Current password'),
              SizedBox(
                height: 24,
              ),
              InputFieldAtom(
                  controller: _newPasswordController,
                  state: _newPasswordFieldState,
                  obscureText: true,
                  placeholder: 'New password'),
              SizedBox(
                height: 24,
              ),
              InputFieldAtom(
                  controller: _retypeNewPasswordController,
                  state: _retypeNewPasswordFieldState,
                  obscureText: true,
                  placeholder: 'Retype new password'),
              SizedBox(
                height: 48,
              ),
              CustomButton(
                label: 'Change password',
                type: ButtonType.primary,
                size: ButtonSize.large,
                onTap: () async {
                  final currentPassword = _currentPasswordController.text;
                  final newPassword = _newPasswordController.text;
                  final retypeNewPassword = _retypeNewPasswordController.text;
                  setState(() {
                    _currentPasswordFieldState = InputFieldState.defaultState;
                    _newPasswordFieldState = InputFieldState.defaultState;
                    _retypeNewPasswordFieldState = InputFieldState.defaultState;
                  });
                  if (newPassword != retypeNewPassword) {
                    setState(() {
                      _retypeNewPasswordFieldState = InputFieldState.error;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('New passwords do not match'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (newPassword.length < 6) {
                    setState(() {
                      _newPasswordFieldState = InputFieldState.error;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Password must be at least 6 characters'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }
                  // Call AuthService
                  final success = await AuthService().changePassword(
                    customerId: widget.customerId,
                    token: widget.token,
                    oldPassword: currentPassword,
                    newPassword: newPassword,
                  );
                  if (success) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const PasswordChangedPage(),
                      ),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Failed to change password'),
                          backgroundColor: Colors.red),
                    );
                  }
                },
                customHeight: 56,
                customWidth: 360,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
