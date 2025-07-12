import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/service_history_page.dart';

class ServiceManagementDemo extends StatelessWidget {
  const ServiceManagementDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: const CustomAppBar(
        title: 'Service Management Demo',
        showTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32.0),
            Text(
              'Service History Integration',
              style: AppTextStyles.textLgSemibold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'This demo shows the integration of verified and unverified service records in the service history.',
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.neutral200,
              ),
            ),
            const SizedBox(height: 32.0),

            // Features List
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features:',
                    style: AppTextStyles.textMdSemibold.copyWith(
                      color: AppColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildFeatureItem(
                      '✓ Add unverified service records from external service centers'),
                  _buildFeatureItem(
                      '✓ Track service provider, location, cost, and notes'),
                  _buildFeatureItem(
                      '✓ Visual distinction between verified and unverified records'),
                  _buildFeatureItem('✓ Combined service history view'),
                  _buildFeatureItem('✓ Form validation and error handling'),
                  _buildFeatureItem('✓ Local storage for unverified records'),
                ],
              ),
            ),

            const SizedBox(height: 48.0),

            // Navigate to Service History Button
            CustomButton(
              label: 'View Service History',
              type: ButtonType.primary,
              size: ButtonSize.large,
              customWidth: double.infinity,
              leadingIcon: Icons.history,
              showLeadingIcon: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServiceHistoryPage(
                    vehicleId: 1,
                    vehicleName: 'Mustang 1977',
                    vehicleRegistration: 'AB89B395',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // Info Text
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.neutral500,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: AppColors.neutral300),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary200,
                    size: 24.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      'In the service history page, tap "Add Service Record" to add unverified services from external providers.',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral150,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: AppTextStyles.textSmRegular.copyWith(
          color: AppColors.neutral150,
        ),
      ),
    );
  }
}
