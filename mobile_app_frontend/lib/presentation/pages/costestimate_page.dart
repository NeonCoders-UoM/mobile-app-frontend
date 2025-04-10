import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/cost_estimate_table.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class CostEstimatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Janaka Motors",
                style: AppTextStyles.body3Bold
                    .copyWith(color: AppColors.neutral200),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                height: 192,
                width: 400,
                decoration: BoxDecoration(
                  color: Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    InfoText(
                      label: "Vehicle Registration No",
                      value: "AB3424",
                    ),
                    InfoText(label: "Appointment Date", value: "12/03/2025"),
                    InfoText(label: "Loyalty Points", value: "4524"),
                    InfoText(label: "Service Center ID", value: "3421"),
                    InfoText(
                        label: "Address",
                        value: "No: 109, Galle Road, Moratuwa"),
                    InfoText(label: "Distance", value: "25 km away"),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Expanded(child: CostEstimateTable()),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  final String label;
  final String value;

  const InfoText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: "$label : ",
          style:
              AppTextStyles.body3Regular.copyWith(color: AppColors.neutral200),
          children: [
            TextSpan(
              text: value,
              style: AppTextStyles.body3Regular
                  .copyWith(color: AppColors.neutral200),
            ),
          ],
        ),
      ),
    );
  }
}
