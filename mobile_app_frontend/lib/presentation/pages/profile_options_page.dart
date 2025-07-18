import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/profile_option_card.dart';
import 'package:mobile_app_frontend/presentation/pages/edit_personaldetails_page.dart';

class ProfileOptionPage extends StatelessWidget {
  final int customerId;
  final String token;

  const ProfileOptionPage({
    super.key,
    required this.customerId,
    required this.token,
  });

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
            ProfileOptionCard(
              text: 'Edit Personal Details',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPersonaldetailsPage(
                      customerId: customerId,
                      token: token,
                    ),
                  ),
                );

                // If edit was successful, show a message and return result to parent
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Details updated! Going back to refresh data.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Return true to indicate data was updated
                  Navigator.of(context).pop(true);
                }
              },
            ),
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
