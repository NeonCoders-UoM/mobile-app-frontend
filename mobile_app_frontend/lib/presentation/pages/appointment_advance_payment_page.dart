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
      final paymentFields =
          sessionData['paymentFields'] as Map<String, dynamic>;

      // Prepare payment object for PayHere SDK
      final paymentObject = {
        "sandbox": true,
        "merchant_id": paymentFields['merchant_id'],
        "merchant_secret":
            "NjEyMTA2MDk3Mjg1MDExODAwMjc5NTUwNTk1MjEwNTg3OTg0MA==", // App-specific merchant secret
        "notify_url":
            "https://d2ba38d700ef.ngrok-free.app/api/payhere/notify", // Your ngrok URL
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
      };

      // Debug logging
      print('🔍 ========== APPOINTMENT PAYMENT DEBUG ==========');
      print('🔍 Merchant ID: ${paymentObject["merchant_id"]}');
      print(
          '🔍 Merchant Secret: ${paymentObject["merchant_secret"]?.toString().substring(0, 10)}...');
      print('🔍 Notify URL: ${paymentObject["notify_url"]}');
      print('🔍 Order ID: ${paymentObject["order_id"]}');
      print(
          '🔍 Amount: ${paymentObject["amount"]} ${paymentObject["currency"]}');
      print('🔍 ==========================================');

      setState(() {
        isLoading = false;
      });

      print('🚀 Starting PayHere payment for appointment...');
      // Start PayHere payment within the app
      PayHere.startPayment(
        paymentObject,
        (paymentId) async {
          print('✅ Appointment payment successful! Payment ID: $paymentId');
          
          // Confirm payment with backend
          try {
            print('📤 Confirming appointment payment with backend...');
            print('   Order ID: ${paymentObject["order_id"]}');
            print('   Payment ID: $paymentId');
            
            final confirmResponse = await dio.post(
              'http://192.168.8.161:5039/api/payhere/confirm-payment',
              data: {
                'orderId': paymentObject["order_id"],
                'paymentNo': paymentId,
                'statusCode': 2, // 2 = Success in PayHere
              },
            );

            if (confirmResponse.statusCode == 200) {
              print('✅ Appointment payment confirmed with backend successfully');
              print('   Backend response: ${confirmResponse.data['message']}');
            } else {
              print('⚠️ Backend confirmation failed: ${confirmResponse.statusCode}');
              print('   Response: ${confirmResponse.data}');
              // Continue anyway - user has paid
            }
          } catch (e) {
            print('❌ Error confirming appointment payment with backend: $e');
            // Continue anyway - user has paid
          }
          
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
          print('❌ Appointment payment failed: $error');
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
          print('❌ Appointment payment cancelled by user');
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
      print('❌ Error in payment flow: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral500,
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
                              // Hero Section
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary200,
                                      AppColors.primary300,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.primary200.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.payment,
                                        size: 48,
                                        color: AppColors.neutral100,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Advance Payment',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.neutral100,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rs. ${paymentCalculation!.advancePaymentAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.neutral100,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Payment Summary Card
                              Container(
                                width: double.infinity,
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
                                  borderRadius: BorderRadius.circular(20),
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.primary200,
                                                AppColors.primary300,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.receipt_long,
                                            color: AppColors.neutral100,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Payment Summary',
                                          style: AppTextStyles.textLgSemibold
                                              .copyWith(
                                            color: AppColors.neutral100,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    _buildPaymentRow('Service Center',
                                        paymentCalculation!.serviceCenterName),
                                    _buildPaymentRow(
                                        'Vehicle',
                                        paymentCalculation!
                                            .vehicleRegistration),
                                    _buildPaymentRow('Appointment Date',
                                        '${paymentCalculation!.appointmentDate.day}/${paymentCalculation!.appointmentDate.month}/${paymentCalculation!.appointmentDate.year}'),
                                    const SizedBox(height: 12),
                                    Divider(
                                        color: AppColors.neutral300
                                            .withOpacity(0.3)),
                                    const SizedBox(height: 12),
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
                                  borderRadius: BorderRadius.circular(20),
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.primary200,
                                                AppColors.primary300,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.info_outline,
                                            color: AppColors.neutral100,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Terms & Conditions',
                                          style: AppTextStyles.textMdSemibold
                                              .copyWith(
                                            color: AppColors.neutral100,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
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
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _proceedToPayment,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.primary200,
                                            AppColors.primary300,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary200
                                                .withOpacity(0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Proceed to Payment - Rs. ${paymentCalculation!.advancePaymentAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Cancel Button
                              SizedBox(
                                width: double.infinity,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      decoration: BoxDecoration(
                                        color: AppColors.neutral400
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.neutral300
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Cancel Booking',
                                          style: TextStyle(
                                            color: AppColors.neutral100,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral200,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.textSmSemibold.copyWith(
              color:
                  isHighlighted ? AppColors.primary200 : AppColors.neutral100,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primary200,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral100,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
