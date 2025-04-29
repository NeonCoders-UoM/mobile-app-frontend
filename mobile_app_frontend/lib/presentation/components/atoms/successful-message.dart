import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class SuccessfulMessage extends StatelessWidget {
  final String para1;
  final String para2;

  const SuccessfulMessage({
    super.key,
    required this.para1,
    required this.para2,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        child: Column(
          children: [
            Text(
              para1,
              style: AppTextStyles.displaySmSemibold.copyWith(
                color: AppColors.neutral150,
              ),
            ),
            const SizedBox(height: 48),
            Image.asset(
              'icons/success_msg.png',
              height: 96,
              width: 96,
            ),
            const SizedBox(height: 48),
            Text(
              textAlign: TextAlign.center,
              para2,
              style: AppTextStyles.textMdRegular
                  .copyWith(color: AppColors.neutral150),
            ),
          ],
        ),
      ),
    );
  }
}
