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
      backgroundColor: AppColors.neutral500,
      appBar: AppBar(
        backgroundColor: AppColors.neutral500,
        elevation: 0,
        title: const Text('Pay & Download PDF'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            color: AppColors.neutral400,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pay Rs.500 to download your Service History PDF',
                    style: AppTextStyles.textLgBold
                        .copyWith(color: AppColors.primary200),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _startPayment,
                      icon: const Icon(Icons.lock_open, color: Colors.white),
                      label: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Pay & Download',
                              style: AppTextStyles.textMdSemibold
                                  .copyWith(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary200,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
