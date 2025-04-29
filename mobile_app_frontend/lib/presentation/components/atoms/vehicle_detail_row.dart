import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class VehicleDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const VehicleDetailRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: RichText(
        text: TextSpan(
          text: '$label\n',
          style: AppTextStyles.textSmRegular.copyWith(
            color: AppColors.neutral300,
          ),
          children: [
            TextSpan(
              text: value,
              style: AppTextStyles.textMdBold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
