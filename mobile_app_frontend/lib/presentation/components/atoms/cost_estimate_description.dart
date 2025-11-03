import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class CostEstimateDescription extends StatelessWidget {
  final String servicecenterName;
  final String? vehicleRegNo;
  final String appointmentDate;
  final String? loyaltyPoints;
  final String serviceCenterId;
  final String? address;
  final String? distance;
  final List<String?>? services;

  const CostEstimateDescription({
    super.key,
    required this.servicecenterName,
    this.vehicleRegNo,
    required this.appointmentDate,
    this.loyaltyPoints,
    required this.serviceCenterId,
    this.address,
    this.distance,
    this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral500,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('Vehicle Registration No : $vehicleRegNo',
          //     style: AppTextStyles.textSmRegular
          //         .copyWith(color: AppColors.neutral200)),
          const SizedBox(height: 10),
          if (appointmentDate?.isNotEmpty == true) ...[
            Text('Appointment Date : $appointmentDate',
                style: AppTextStyles.textSmRegular
                    .copyWith(color: AppColors.neutral200)),
            const SizedBox(height: 10),
          ],
          if (loyaltyPoints?.isNotEmpty == true) ...[
            Text('Loyalty Points : $loyaltyPoints',
                style: AppTextStyles.textSmRegular
                    .copyWith(color: AppColors.neutral200)),
            const SizedBox(height: 10),
          ],
          if (serviceCenterId?.isNotEmpty == true) ...[
            Text('Service Center ID : $serviceCenterId',
                style: AppTextStyles.textSmRegular
                    .copyWith(color: AppColors.neutral200)),
            const SizedBox(height: 10),
          ],
          if (address?.isNotEmpty == true) ...[
            Text('Address : $address',
                style: AppTextStyles.textSmRegular
                    .copyWith(color: AppColors.neutral200)),
            const SizedBox(height: 10),
          ],
          if (distance?.isNotEmpty == true) ...[
            Text('Distance : $distance',
                style: AppTextStyles.textSmRegular
                    .copyWith(color: AppColors.neutral200)),
          ],
        ],
      ),
    );
  }
}
