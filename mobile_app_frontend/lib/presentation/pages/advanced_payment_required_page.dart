import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/pages/costestimate_page.dart';
import 'package:mobile_app_frontend/presentation/pages/select_payment_method_page.dart';

class AdvancedPaymentRequiredPage extends StatefulWidget {
  final int customerId;
  final int vehicleId;
  final String token;
  final int appointmentId;
  final double totalCost;

  const AdvancedPaymentRequiredPage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
    required this.token,
    required this.appointmentId,
    required this.totalCost,
  }) : super(key: key);

  @override
  State<AdvancedPaymentRequiredPage> createState() =>
      _AdvancedPaymentRequiredPageState();
}

class _AdvancedPaymentRequiredPageState
    extends State<AdvancedPaymentRequiredPage> {
  double advancePaymentAmount = 0.0;
  double remainingAmount = 0.0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _calculateAdvancePayment();
  }

  void _calculateAdvancePayment() {
    if (widget.totalCost < 10000) {
      advancePaymentAmount = widget.totalCost * 0.10; // 10% of total cost
    } else {
      advancePaymentAmount = 1000.0; // Fixed Rs. 1000 for costs >= Rs. 10,000
    }
    remainingAmount = widget.totalCost - advancePaymentAmount;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: CustomAppBar(
        title: '',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
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
                      'To secure your appointment, you must make an advance payment of Rs.${advancePaymentAmount.toStringAsFixed(2)}. The remaining amount of Rs.${remainingAmount.toStringAsFixed(2)} will be paid at the service center after your service is completed.',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral150,
                        fontSize: 12.0,
                      ),
                      textAlign: TextAlign.center,
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectPaymentMethodPage(
                                    customerId: widget.customerId,
                                    vehicleId: widget.vehicleId,
                                    token: widget.token,
                                    appointmentId: widget.appointmentId,
                                    advancePaymentAmount:
                                        advancePaymentAmount))),
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
                          MaterialPageRoute(
                            builder: (context) => CostEstimatePage(
                              customerId: widget.customerId,
                              vehicleId: widget.vehicleId,
                              token: widget.token,
                              appointmentId: widget.appointmentId,
                            ),
                          ),
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
