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
        title: 'Advance Payment',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary200,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Advance Payment Required',
                      style: AppTextStyles.textLgSemibold.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'To secure your appointment, you must make an advance payment of Rs.${advancePaymentAmount.toStringAsFixed(2)}. The remaining amount of Rs.${remainingAmount.toStringAsFixed(2)} will be paid at the service center after your service is completed.',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral200,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.neutral450,
                            AppColors.neutral450.withOpacity(0.95),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms & Conditions',
                            style: AppTextStyles.textSmSemibold.copyWith(
                              color: AppColors.neutral100,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: AppColors.states['ok'],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Advance payments are non-refundable under any circumstances.',
                                  style: AppTextStyles.textSmRegular.copyWith(
                                    color: AppColors.neutral200,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: AppColors.states['ok'],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Appointments cannot be rescheduled.',
                                  style: AppTextStyles.textSmRegular.copyWith(
                                    color: AppColors.neutral200,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      label: 'Proceed to Payment',
                      type: ButtonType.primary,
                      size: ButtonSize.large,
                      customWidth: double.infinity,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectPaymentMethodPage(
                              customerId: widget.customerId,
                              vehicleId: widget.vehicleId,
                              token: widget.token,
                              appointmentId: widget.appointmentId,
                              advancePaymentAmount: advancePaymentAmount,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
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
                          );
                        },
                        child: Text(
                          'Cancel Booking',
                          style: AppTextStyles.textMdSemibold.copyWith(
                            color: AppColors.neutral200,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
