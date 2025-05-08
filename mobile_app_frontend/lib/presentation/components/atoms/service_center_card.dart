import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/pages/costestimate_page.dart';

class ServiceCenterCard extends StatelessWidget {
  final String servicecenterName;
  final String address;
  final String distance;
  final String loyaltyPoints;
  final String estimatedCost;

  const ServiceCenterCard({
    super.key,
    required this.servicecenterName,
    required this.address,
    required this.distance,
    required this.loyaltyPoints,
    required this.estimatedCost,
  });

  /*void _handleview() {
    print('Generating the invoice');
  }
  */

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.neutral400,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 3,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neutral450,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutral450.withOpacity(0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servicecenterName,
                    style: AppTextStyles.textMdSemibold.copyWith(
                      color: AppColors.neutral100,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address,
                    style: AppTextStyles.textMdRegular
                        .copyWith(color: AppColors.neutral150),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    distance,
                    style: AppTextStyles.textMdRegular
                        .copyWith(color: AppColors.neutral150),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Loyalty Points : $loyaltyPoints",
                    style: AppTextStyles.textMdRegular
                        .copyWith(color: AppColors.neutral150),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Estimated Cost : $estimatedCost",
                    style: AppTextStyles.textMdRegular
                        .copyWith(color: AppColors.neutral150),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 68,
                height: 40,
                child: CustomButton(
                  label: 'View',
                  type: ButtonType.primary,
                  size: ButtonSize.small,
                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CostEstimatePage()))
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
