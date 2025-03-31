import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class VehicleHeader extends StatelessWidget {
  final String vehicleName;
  final String vehicleId;

  const VehicleHeader({
    Key? key,
    required this.vehicleName,
    required this.vehicleId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              vehicleName.toUpperCase(),
              style: AppTextStyles.displayMdBold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              vehicleId,
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.neutral100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
