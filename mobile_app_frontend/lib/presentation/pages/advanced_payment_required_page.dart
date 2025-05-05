import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/pages/costestimate_page.dart';
import 'package:mobile_app_frontend/presentation/pages/select_payment_method_page.dart';


class AdvancedPaymentRequiredPage extends StatelessWidget {
  const AdvancedPaymentRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: CustomAppBar(title: '',onBackPressed: () => Navigator.of(context).pop(),),
      body: Center(
        child: SizedBox(
          width: 380,
          child: Column(
            children: [
              Text(
                'Advance Payment Required',
                style: AppTextStyles.textLgSemibold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
              SizedBox(
                height: 28,
              ),
              Text(
                '" To secure your appointment, you must make an advance payment of Rs.1500. The remaining amount will be paid at the service center after your service is completed. "',
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.neutral150,
                  fontSize: 12.0,
                ),
              ),
              SizedBox(
                height: 32,
              ),
              Container(
                width: 380,
                height: 104,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Terms & Conditions',
                      style: AppTextStyles.textXsmRegular.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/green_tick.png',
                          height: 24,
                          width: 24,
                        ),
                        Text(
                          'Advance payments are non-refundable under any circumstances.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.normal,
                            color: AppColors.neutral400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/green_tick.png',
                          height: 24,
                          width: 24,
                        ),
                        Text(
                          'Appointments cannot be rescheduled.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.normal,
                            color: AppColors.neutral400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 52,
              ),
              CustomButton(
                label: 'Proceed to Payment',
                type: ButtonType.primary,
                size: ButtonSize.large,
                onTap: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectPaymentMethodPage())),
                },
                customHeight: 56,
                customWidth: 380,
              ),
              SizedBox(
                height: 32,
              ),
              CustomButton(
                label: 'Cancel Booking',
                type: ButtonType.danger,
                size: ButtonSize.large,
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CostEstimatePage()),
                  )
                },
                customHeight: 56,
                customWidth: 380,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
