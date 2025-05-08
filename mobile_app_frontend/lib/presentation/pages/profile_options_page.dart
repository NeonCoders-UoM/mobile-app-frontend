import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/profile_option_card.dart';
import 'package:mobile_app_frontend/presentation/pages/delete_account_page.dart';
import 'package:mobile_app_frontend/presentation/pages/change_password_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetails_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';

class ProfileOptionPage extends StatelessWidget {
  const ProfileOptionPage({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar:  CustomAppBar(
        title: 'Profile',
        onBackPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VehicleDetailsPage ())),
        showTitle: true,
       
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 12),
            ProfileOptionCard(
              text: 'Edit Personal Details',
              onTap:() =>  _navigate(context, const DeleteAccountPage()),
            ),
            const SizedBox(height: 4),
            ProfileOptionCard(
              text: 'Delete Account',
              onTap: () => _navigate(context, const DeleteAccountPage()),
            ),
            const SizedBox(height: 4),
            ProfileOptionCard(
              text: 'Change Password',
              onTap: () => _navigate(context, const ChangePasswordPage()),
            ),
            const SizedBox(height: 4),
            ProfileOptionCard(
              text: 'Add New Vehicle',
              onTap: () => _navigate(context, const VehicledetailsPage()),
            ),
          ],
        ),
      ),
    );
  }
}
