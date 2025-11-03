import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';

class AppointmentPaymentSuccessPage extends StatelessWidget {
  final int customerId;
  final int vehicleId;
  final String token;
  final int appointmentId;

  const AppointmentPaymentSuccessPage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
    required this.token,
    required this.appointmentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.states['ok']!,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Success Message
              Text(
                'Payment Successful!',
                style: AppTextStyles.textLgSemibold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Your appointment has been confirmed',
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.neutral150,
                ),
              ),

              const SizedBox(height: 32),

              // Appointment Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment Details',
                      style: AppTextStyles.textLgSemibold.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Appointment ID',
                        '#APT-${appointmentId.toString().padLeft(6, '0')}'),
                    _buildDetailRow('Status', 'Paid'),
                    _buildDetailRow('Payment Status', 'Advance Paid'),
                  ],
                ),
              ),

              const Spacer(),

              // Home Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Go to Home',
                  type: ButtonType.primary,
                  size: ButtonSize.large,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VehicleDetailsHomePage(
                          customerId: customerId,
                          token: token,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.textSmSemibold.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
