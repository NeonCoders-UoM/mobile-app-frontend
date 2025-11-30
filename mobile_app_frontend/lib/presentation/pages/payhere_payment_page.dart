import 'package:flutter/material.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/payment_successful_message_page.dart';
import 'package:mobile_app_frontend/core/services/local_storage.dart';

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

    final paymentObject = {
      "sandbox": true,
      "merchant_id": "1230582",
      "merchant_secret":
          "MzQxNjgzNzU1NTE2ODA1MjMzMzM0MjkwNzU3OTIyMjMxMTY0NjcyNQ==",
      "notify_url":
          "http://192.168.8.161:5039/api/payhere/notify", // Your server notify endpoint (must be publicly accessible)
      "order_id":
          "vehicle_${widget.vehicleId}_${DateTime.now().millisecondsSinceEpoch}",
      "items": "Service History PDF",
      "amount": "500.00",
      "currency": "LKR",
      "first_name": widget.customerName.split(' ').first,
      "last_name": widget.customerName.split(' ').length > 1
          ? widget.customerName.split(' ').sublist(1).join(' ')
          : "",
      "email": widget.customerEmail,
      "phone": "0771234567",
      "address": "No.1, Galle Road",
      "city": "Colombo",
      "country": "Sri Lanka",
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

    // Validation: Check if merchant secret is still placeholder
    if (paymentObject["merchant_secret"] ==
        "YOUR_ACTUAL_MERCHANT_SECRET_HERE") {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '⚠️ Please update merchant secret in payhere_payment_page.dart!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      print('❌ ERROR: Merchant secret not configured!');
      return;
    }

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
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _startPayment,
                    icon: const Icon(Icons.lock_open, color: Colors.white),
                    label: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Pay & Download',
                            style: AppTextStyles.textMdSemibold
                                .copyWith(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary200,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
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
