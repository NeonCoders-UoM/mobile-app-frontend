import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/custom_button.dart';

class ServiceCenterCard extends StatelessWidget {
  final String name;
  final String address;
  final String distance;
  final String loyaltyPoints;
  final String estimatedCost;

  const ServiceCenterCard({
    super.key,
    required this.name,
    required this.address,
    required this.distance,
    required this.loyaltyPoints,
    required this.estimatedCost,
  });

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
                    name,
                    style: AppTextStyles.textMdBold.copyWith(
                      color: AppColors.neutral100,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: AppTextStyles.textMdBold
                        .copyWith(color: AppColors.neutral150),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    distance,
                    style: AppTextStyles.textMdBold
                        .copyWith(color: AppColors.neutral150),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Loyalty Points : $loyaltyPoints",
                    style: AppTextStyles.textMdBold
                        .copyWith(color: AppColors.neutral150),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Estimated Cost : $estimatedCost",
                    style: AppTextStyles.textMdBold
                        .copyWith(color: AppColors.neutral150),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right side - View Button
            //CustomButton(text: "View", onPressed: () {})
          ],
        ),
      ),
    );
  }
}
