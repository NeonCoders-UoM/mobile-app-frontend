import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class StatusDot extends StatelessWidget {
  final String status;
  final Color dotColor;

  const StatusDot({
    super.key,
    required this.status,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          status,
          style: AppTextStyles.textXsmRegular.copyWith(
            color: AppColors.neutral200, // Light gray for status text
          ),
        ),
      ],
    );
  }
}
