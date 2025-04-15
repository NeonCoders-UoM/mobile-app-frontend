import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';

class EmergencyservicePage extends StatelessWidget {
  const EmergencyservicePage({super.key});

  void _handleCall() async {
    final Uri callUri = Uri(scheme: 'tel', path: '+94703681620');

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch dialer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Emergency Service',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            Container(
              height: 220, // adjust this height as needed
              width: 442,
              child: Image.asset(
                'assets/images/emergency_garage.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 32),

            // Garage Name
            Text(
              'Adonz Automotive',
              style: AppTextStyles.textLgBold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 4),

            // Location
            Text(
              'Moratuwa, Sri Lanka',
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral200,
              ),
            ),
            const SizedBox(height: 40),

            // Description
            Text(
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
              'Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s.\n\n'
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
              'Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, '
              'when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 120),

            // Call to Action Button
            Center(
              child: SizedBox(
                width: 220,
                height: 48,
                child: CustomButton(
                  label: 'Call',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: _handleCall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
