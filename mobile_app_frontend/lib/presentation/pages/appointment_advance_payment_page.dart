import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/data/models/advance_payment_model.dart';
import 'package:mobile_app_frontend/data/repositories/payment_repository.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_payment_success_page.dart';
import 'package:dio/dio.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';

class AppointmentAdvancePaymentPage extends StatefulWidget {
  final int customerId;
  final int vehicleId;
  final String token;
  final int appointmentId;
  final double totalCost;

  const AppointmentAdvancePaymentPage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
    required this.token,
    required this.appointmentId,
    required this.totalCost,
  }) : super(key: key);

  @override
  State<AppointmentAdvancePaymentPage> createState() =>
      _AppointmentAdvancePaymentPageState();
}

class _AppointmentAdvancePaymentPageState
    extends State<AppointmentAdvancePaymentPage> {
  AdvancePaymentCalculation? paymentCalculation;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPaymentCalculation();
  }

  Future<void> _loadPaymentCalculation() async {
    try {
      final dio = Dio();
      final paymentRepo = PaymentRepository(dio);

      final calculation = await paymentRepo.calculateAdvancePayment(
        appointmentId: widget.appointmentId,
        customerId: widget.customerId,
        vehicleId: widget.vehicleId,
        token: widget.token,
      );

      setState(() {
        paymentCalculation = calculation;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _proceedToPayment() async {
    if (paymentCalculation == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final dio = Dio();
      final paymentRepo = PaymentRepository(dio);

      // Create PayHere session
      final sessionData = await paymentRepo.createPayHereSession(
        appointmentId: widget.appointmentId,
        customerId: widget.customerId,
        vehicleId: widget.vehicleId,
        amount: paymentCalculation!.advancePaymentAmount,
        userEmail: 'customer@example.com', // TODO: Get from user profile
        userName: 'Customer Name', // TODO: Get from user profile
        token: widget.token,
      );

      // Use PayHere mobile SDK for in-app payment
      final paymentFields = sessionData['paymentFields'] as Map<String, dynamic>;
      
      // Prepare payment object for PayHere SDK
      final paymentObject = {
        "sandbox": true,
        "merchant_id": paymentFields['merchant_id'],
        "notify_url": paymentFields['notify_url'],
        "order_id": paymentFields['order_id'],
        "items": paymentFields['items'],
        "amount": paymentFields['amount'],
        "currency": paymentFields['currency'],
        "first_name": paymentFields['first_name'],
        "last_name": paymentFields['last_name'] ?? '',
        "email": paymentFields['email'],
        "phone": paymentFields['phone'],
        "address": paymentFields['address'],
        "city": paymentFields['city'],
        "country": paymentFields['country'],
        "hash": paymentFields['hash'],
      };

      setState(() {
        isLoading = false;
      });

      // Start PayHere payment within the app
      PayHere.startPayment(
        paymentObject,
        (paymentId) async {
          // Payment successful
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AppointmentPaymentSuccessPage(
                appointmentId: widget.appointmentId,
                customerId: widget.customerId,
                vehicleId: widget.vehicleId,
                token: widget.token,
              ),
            ),
          );
        },
        (error) {
          // Payment failed
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        () {
          // Payment cancelled
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment cancelled'),
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text('Error: $errorMessage'))
                  : paymentCalculation == null
                      ? const Center(
                          child: Text('No payment calculation available'))
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Payment Summary Card
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
                                      'Payment Summary',
                                      style:
                                          AppTextStyles.textLgSemibold.copyWith(
                                        color: AppColors.neutral400,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPaymentRow('Service Center',
                                        paymentCalculation!.serviceCenterName),
                                    _buildPaymentRow(
                                        'Vehicle',
                                        paymentCalculation!
                                            .vehicleRegistration),
                                    _buildPaymentRow('Appointment Date',
                                        '${paymentCalculation!.appointmentDate.day}/${paymentCalculation!.appointmentDate.month}/${paymentCalculation!.appointmentDate.year}'),
                                    const Divider(),
                                    _buildPaymentRow('Total Cost',
                                        'Rs. ${paymentCalculation!.totalCost.toStringAsFixed(2)}'),
                                    _buildPaymentRow('Advance Payment',
                                        'Rs. ${paymentCalculation!.advancePaymentAmount.toStringAsFixed(2)}',
                                        isHighlighted: true),
                                    _buildPaymentRow('Remaining Amount',
                                        'Rs. ${paymentCalculation!.remainingAmount.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Terms and Conditions
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Terms & Conditions',
                                      style:
                                          AppTextStyles.textMdSemibold.copyWith(
                                        color: AppColors.neutral400,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildTermItem(
                                        'Advance payments are non-refundable under any circumstances.'),
                                    _buildTermItem(
                                        'Appointments cannot be rescheduled.'),
                                    _buildTermItem(
                                        'Remaining amount must be paid at the service center.'),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Payment Button
                              SizedBox(
                                width: double.infinity,
                                child: CustomButton(
                                  label:
                                      'Proceed to Payment - Rs. ${paymentCalculation!.advancePaymentAmount.toStringAsFixed(2)}',
                                  type: ButtonType.primary,
                                  size: ButtonSize.large,
                                  onTap: _proceedToPayment,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Cancel Button
                              SizedBox(
                                width: double.infinity,
                                child: CustomButton(
                                  label: 'Cancel Booking',
                                  type: ButtonType.danger,
                                  size: ButtonSize.large,
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value,
      {bool isHighlighted = false}) {
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
              color:
                  isHighlighted ? AppColors.primary200 : AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.states['ok']!,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
