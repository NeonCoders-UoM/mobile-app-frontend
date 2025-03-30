import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class AddReminderButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddReminderButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(8.0),
        color: AppColors.neutral100.withOpacity(0.5),
        strokeWidth: 1.0,
        dashPattern: const [5, 3],
        child: Container(
          width: double.infinity,
          height: 56.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Simple plus icon without the circle
              const Icon(
                Icons.add,
                size: 24.0,
                color: AppColors.neutral100,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Add Reminders',
                style: AppTextStyles.textLgSemibold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
