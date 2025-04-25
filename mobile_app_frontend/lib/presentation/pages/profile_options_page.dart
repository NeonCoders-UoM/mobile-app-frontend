import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/profile_option_card.dart';

class ProfileOptionPage extends StatelessWidget {
  const ProfileOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: const CustomAppBar(
        title: 'Profile',
        showTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 12,
            ),
            ProfileOptionCard(text: 'Edit Personal Details'),
            SizedBox(
              height: 4,
            ),
            ProfileOptionCard(text: 'Delete Account'),
            SizedBox(
              height: 4,
            ),
            ProfileOptionCard(text: 'Change Password'),
            SizedBox(
              height: 4,
            ),
            ProfileOptionCard(text: 'Add New Vehicle')
          ],
        ),
      ),
    );
  }
}
