import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/service_center_card.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';

class ServiceCenterPage extends StatelessWidget {
  const ServiceCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: AppBar(
        title: const Text("Near By Partnered Service Centers"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return const ServiceCenterCard(
              name: "Janaka Motors",
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
