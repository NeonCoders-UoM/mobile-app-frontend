import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';

import 'package:mobile_app_frontend/presentation/pages/account_deleted_page.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';

class DeleteAccountPage extends StatefulWidget {
  final int customerId;
  final String token;
  const DeleteAccountPage(
      {super.key, required this.customerId, required this.token});
  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _passwordController = TextEditingController();
  InputFieldState _passwordFieldState = InputFieldState.defaultState;
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: CustomAppBar(title: 'Delete Account'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Are you sure you want to delete your account?',
              style: AppTextStyles.textLgSemibold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Once you delete your account, it cannot be undone. All your data will be permanently erased from this app including your profile information, preferences, saved content, and any activity history.',
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral200,
              ),
            ),
            const SizedBox(height: 32),
            InputFieldAtom(
              controller: _passwordController,
              state: _passwordFieldState,
              placeholder: 'Password',
              label: 'Enter your password',
              obscureText: _obscurePassword,
              showTrailingIcon: true,
              trailingIcon:
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
              onTrailingIconTap: _togglePasswordVisibility,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final password = _passwordController.text;
                final success = await AuthService().deleteAccount(
                  customerId: widget.customerId,
                  token: widget.token,
                  password: password,
                );
                if (success) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const AccountDeletedPage()),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to delete account'),
                        backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Delete Account',
                style: AppTextStyles.textMdSemibold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.textMdSemibold.copyWith(
                    color: AppColors.neutral200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
