import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';

class AppointmentCard extends StatelessWidget {
  final String garageName;
  final String date;
  final VoidCallback? onInvoicePressed;

  const AppointmentCard({
    super.key,
    required this.garageName,
    required this.date,
    this.onInvoicePressed,
  });

  void _onInvoicePressed() {
    print('Generating the invoice');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.neutral400,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Container(
        width: 360,
        height: 152,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neutral450,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutral450.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home, color: AppColors.neutral150, size: 18),
                const SizedBox(width: 8),
                Text(
                  garageName,
                  style: AppTextStyles.textLgMedium.copyWith(
                    color: AppColors.neutral150,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time,
                    color: AppColors.neutral150, size: 18),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: AppTextStyles.textLgMedium.copyWith(
                    color: AppColors.neutral150,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 84,
                height: 40,
                child: CustomButton(
                  label: 'Invoice',
                  type: ButtonType.primary,
                  size: ButtonSize.small,
                  onTap: _onInvoicePressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
