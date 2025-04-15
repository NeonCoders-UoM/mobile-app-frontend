import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddPhotoButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Take full width of the parent
        padding: const EdgeInsets.only(
          left: 12.0, // Reduced left padding
          right: 12.0, // Match left padding for symmetry
          top: 8.0, // Reduced vertical padding
          bottom: 8.0,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral450, // Dark gray background
          borderRadius: BorderRadius.circular(16.0), // Increased border radius
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: AppColors.neutral100,
              size: 24.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              'Attach Photo',
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
