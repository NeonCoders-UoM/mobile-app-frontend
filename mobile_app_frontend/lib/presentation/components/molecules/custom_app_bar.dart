import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showTitle;
  final VoidCallback?
      onBackPressed; // Optional callback for custom back behavior

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showTitle = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          AppColors.neutral400, // Dark background matching the image
      elevation: 0, // Flat design, no shadow
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_outlined, // Back arrow icon
          color: AppColors.neutral100, // Light color for contrast
          size: 24.0,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: showTitle
          ? Text(
              title,
              style: AppTextStyles.textLgSemibold.copyWith(
                color: AppColors.neutral100, // Light text color for contrast
              ),
            )
          : null,
      centerTitle: true, // Center the title as shown in the image
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
