import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class CustomIconButton extends StatelessWidget {
  final String iconPath; // Path to the SVG icon
  final String label; // Text label below the icon
  final VoidCallback onTap; // Callback for button press
  final double iconSize; // Size of the icon
  final double circleSize; // Size of the circular button
  final Color circleColor; // Background color of the circle
  final Color iconColor; // Color of the SVG icon
  final TextStyle? labelStyle; // Style for the label text

  const CustomIconButton({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.iconSize = 60.0,
    this.circleSize = 60.0,
    this.circleColor = Colors.transparent,
    this.iconColor = AppColors.neutral100,
    this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular button with SVG icon
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              border: Border.all(
                color: Colors.transparent,
                width: 1.0,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                color: iconColor, // Tint the SVG icon
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0), // Space between icon and label
        // Label text below the button
        Text(
          label,
          style: AppTextStyles.textXsmRegular.copyWith(
            color: AppColors.neutral100,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
