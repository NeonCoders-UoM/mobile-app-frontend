import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/service_center_card.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';

class ServiceCenterPage extends StatelessWidget {
  const ServiceCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Near by partner services',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            return const ServiceCenterCard(
              servicecenterName: "Janaka Motors",
              address: "Moratumulla , Moratuwa",
              distance: "25 km away",
              loyaltyPoints: "45.34",
              estimatedCost: "Rs. 40 000",
            );
          },
        ),
      ),
    );
  }
}
