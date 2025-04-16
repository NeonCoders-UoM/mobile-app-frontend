import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class CostEstimateDescription extends StatelessWidget {
  final String servicecenterName;
  final String vehicleRegNo;
  final String appointmentDate;
  final String loyaltyPoints;
  final String serviceCenterId;
  final String address;
  final String distance;

  const CostEstimateDescription({
    super.key,
    required this.servicecenterName,
    required this.vehicleRegNo,
    required this.appointmentDate,
    required this.loyaltyPoints,
    required this.serviceCenterId,
    required this.address,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.neutral400,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutral450.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              servicecenterName,
              style: AppTextStyles.textLgMedium.copyWith(
                color: AppColors.neutral100,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Vehicle Registration No : $vehicleRegNo",
              style: AppTextStyles.textSmRegular
                  .copyWith(color: AppColors.neutral150),
            ),
            const SizedBox(height: 8),
            Text(
              "Appointment Date : $appointmentDate",
              style: AppTextStyles.textSmRegular
                  .copyWith(color: AppColors.neutral150),
            ),
            const SizedBox(height: 8),
            Text(
              "Loyalty Points : $loyaltyPoints",
              style: AppTextStyles.textSmRegular
                  .copyWith(color: AppColors.neutral150),
            ),
            const SizedBox(height: 8),
            Text(
              "Service Center ID : $serviceCenterId",
              style: AppTextStyles.textSmRegular
                  .copyWith(color: AppColors.neutral150),
            ),
            const SizedBox(height: 8),
            Text(
              "Address : $address",
              style: AppTextStyles.textSmRegular
                  .copyWith(color: AppColors.neutral150),
            ),
            const SizedBox(height: 8),
            Text(
              "Distance : $distance",
              style: AppTextStyles.textSmRegular
                  .copyWith(color: AppColors.neutral150),
            ),
          ],
        ),
      ),
    );
  }
}
