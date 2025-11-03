import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class PaymentMethodOption extends StatelessWidget {
  final String label; // e.g., "Visa"
  final String iconPath; // Path to the payment method icon (e.g., Visa logo)
  final VoidCallback onTap; // Callback when the option is tapped

  const PaymentMethodOption({
    Key? key,
    required this.label,
    required this.iconPath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral100),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            // Leading Icon (Payment Method Logo)
            Image.asset(
              iconPath,
              width: 48.0,
              height: 48.0,
            ),
            const SizedBox(width: 16.0),
            // Label
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.textLgRegular
                    .copyWith(color: AppColors.neutral100),
              ),
            ),
            // Trailing Arrow Icon
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.neutral100,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
