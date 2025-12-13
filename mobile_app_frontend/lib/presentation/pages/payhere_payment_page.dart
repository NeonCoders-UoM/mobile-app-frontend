import 'package:flutter/material.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/payment_successful_message_page.dart';
import 'package:mobile_app_frontend/core/services/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PayHerePaymentPage extends StatefulWidget {
  final int vehicleId;
  final String customerEmail;
  final String customerName;
  final int? customerId;
  final String? token;

  const PayHerePaymentPage({
    Key? key,
    required this.vehicleId,
    required this.customerEmail,
    required this.customerName,
    this.customerId,
    this.token,
  }) : super(key: key);

  @override
  _PayHerePaymentPageState createState() => _PayHerePaymentPageState();
}

class _PayHerePaymentPageState extends State<PayHerePaymentPage> {
  bool _isProcessing = false;

  void _startPayment() async {
    // Save authentication data before payment redirect
    if (widget.token != null && widget.customerId != null) {
      await LocalStorageService.saveAuthData(
        token: widget.token!,
        customerId: widget.customerId!,
      );

      // Save payment context
      await LocalStorageService.savePaymentContext(
        vehicleId: widget.vehicleId,
        customerEmail: widget.customerEmail,
        customerName: widget.customerName,
      );

      print('💾 Authentication data saved before payment redirect');
    }

    // Create PayHere session via backend (same as appointment payment)
    print('🔄 Creating PayHere session via backend...');
    final response = await http.post(
      Uri.parse('http://192.168.8.161:5039/api/payhere/create-session'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vehicleId': widget.vehicleId,
        'userEmail': widget.customerEmail,
        'userName': widget.customerName,
      }),
    );

    if (response.statusCode != 200) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create payment session: ${response.body}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sessionData = jsonDecode(response.body);
    final paymentFields = sessionData['paymentFields'] as Map<String, dynamic>;

    final paymentObject = {
      "sandbox": true,
      "merchant_id": paymentFields[
          'merchant_id'], // Use backend merchant ID (same as appointment)
      "merchant_secret":
          "NjEyMTA2MDk3Mjg1MDExODAwMjc5NTUwNTk1MjEwNTg3OTg0MA==", // Updated to match backend
      "notify_url":
          "https://d2ba38d700ef.ngrok-free.app/api/payhere/notify", // Your current ngrok URL
      "order_id": paymentFields['order_id'], // Use order_id from backend
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
    print('🔍 ========== PAYHERE PAYMENT DEBUG ==========');
    print('🔍 Merchant ID: ${paymentObject["merchant_id"]}');
    print(
        '🔍 Merchant Secret: ${paymentObject["merchant_secret"]?.toString().substring(0, 10)}...');
    print('🔍 Notify URL: ${paymentObject["notify_url"]}');
    print('🔍 Order ID: ${paymentObject["order_id"]}');
    print('🔍 Amount: ${paymentObject["amount"]} ${paymentObject["currency"]}');
    print(
        '🔍 Customer: ${paymentObject["first_name"]} ${paymentObject["last_name"]}');
    print('🔍 Email: ${paymentObject["email"]}');
    print('🔍 ==========================================');

    setState(() {
      _isProcessing = true;
    });

    print('🚀 Initiating PayHere payment...');
    PayHere.startPayment(
      paymentObject,
      (paymentId) async {
        print('✅ Payment successful! Payment ID: $paymentId');

        // Retrieve saved authentication data
        final authData = await LocalStorageService.getAuthData();
        final paymentContext = await LocalStorageService.getPaymentContext();

        print('🔑 Retrieved auth data: ${authData != null ? "✅" : "❌"}');
        print(
            '📱 Retrieved payment context: ${paymentContext != null ? "✅" : "❌"}');

        // Confirm payment with backend
        try {
          print('📤 Confirming payment with backend...');
          print('   Order ID: ${paymentObject["order_id"]}');
          print('   Payment ID: $paymentId');

          final confirmResponse = await http.post(
            Uri.parse('http://192.168.8.161:5039/api/payhere/confirm-payment'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'orderId': paymentObject["order_id"],
              'paymentNo': paymentId,
              'statusCode': 2, // 2 = Success in PayHere
            }),
          );

          if (confirmResponse.statusCode == 200) {
            print('✅ Payment confirmed with backend successfully');
            final confirmData = jsonDecode(confirmResponse.body);
            print('   Backend response: ${confirmData['message']}');
          } else {
            print(
                '⚠️ Backend confirmation failed: ${confirmResponse.statusCode}');
            print('   Response: ${confirmResponse.body}');
            // Continue anyway - user has paid, we'll handle this manually if needed
          }
        } catch (e) {
          print('❌ Error confirming payment with backend: $e');
          // Continue anyway - user has paid
        }

        if (authData != null && paymentContext != null) {
          print('✅ Using saved authentication data');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentSuccessfulMessagePage(
                vehicleId: paymentContext['vehicleId'],
                token: authData['token'],
                customerId: authData['customerId'],
              ),
            ),
          );

          // Clear payment context after successful navigation
          await LocalStorageService.clearPaymentContext();
        } else {
          print('❌ No saved authentication data found, using widget data');
          // Fallback to widget data
          if (widget.token != null && widget.customerId != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PaymentSuccessfulMessagePage(
                  vehicleId: widget.vehicleId,
                  token: widget.token!,
                  customerId: widget.customerId!,
                ),
              ),
            );
          } else {
            print('❌ No authentication data available');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Authentication error. Please log in again.'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isProcessing = false;
            });
          }
        }
      },
      (error) {
        print('❌ Payment failed: $error');
        // Handle payment error
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $error')),
        );
      },
      () {
        print('❌ Payment cancelled by user');
        // Handle payment cancelled
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment cancelled')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: AppBar(
        backgroundColor: AppColors.neutral400,
        elevation: 0,
        title: Text(
          'Pay & Download PDF',
          style: AppTextStyles.textLgSemibold.copyWith(
            color: AppColors.neutral100,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.neutral100),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
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
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 64,
                      color: AppColors.primary200,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Service History PDF',
                      style: AppTextStyles.textLgSemibold.copyWith(
                        color: AppColors.neutral100,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pay Rs.500 to download your complete service history',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral200,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _startPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary200,
                        disabledBackgroundColor:
                            AppColors.primary300.withOpacity(0.5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_open,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Pay & Download',
                                  style: AppTextStyles.textMdSemibold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
