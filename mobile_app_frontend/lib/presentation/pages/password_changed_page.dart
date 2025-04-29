import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/successful-message.dart';

class PasswordChangedPage extends StatelessWidget {
  const PasswordChangedPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: Column(
        children: [
          SizedBox(
            height: 116,
          ),
          SuccessfulMessage(
              para1: 'Password Changed',
              para2: 'Your password has been changed successfully'),
          SizedBox(
            height: 404,
          ),
          CustomButton(
            label: 'Home',
            type: ButtonType.primary,
            size: ButtonSize.large,
            onTap: () {
              // Handle document addition logic here
            },
            customWidth: 360.0,
            customHeight: 56.0,
          ),
        ],
      ),
    );
  }
}
