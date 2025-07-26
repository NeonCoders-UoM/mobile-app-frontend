import 'package:flutter/material.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class PayHerePaymentPage extends StatefulWidget {
  final int vehicleId;
  final String customerEmail;
  final String customerName;

  const PayHerePaymentPage({
    Key? key,
    required this.vehicleId,
    required this.customerEmail,
    required this.customerName,
  }) : super(key: key);

  @override
  _PayHerePaymentPageState createState() => _PayHerePaymentPageState();
}

class _PayHerePaymentPageState extends State<PayHerePaymentPage> {
  bool _isProcessing = false;

  void _startPayment() {
    final paymentObject = {
      "sandbox": true,
      "merchant_id": "1230582",
      "merchant_secret":
          "MzQxNjgzNzU1NTE2ODA1MjMzMzM0MjkwNzU3OTIyMjMxMTY0NjcyNQ==",
      "notify_url":
          "https://sandbox.payhere.lk/notify", // Your server notify endpoint (must be publicly accessible)
      "order_id":
          "vehicle_${widget.vehicleId}_${DateTime.now().millisecondsSinceEpoch}",
      "items": "Service History PDF",
      "amount": "500.00",
      "currency": "LKR",
      "first_name": widget.customerName,
      "last_name": "", // Optional
      "email": widget.customerEmail,
      "phone": "0771234567", // Optional
      "address": "Colombo",
      "city": "Colombo",
      "country": "Sri Lanka",
      "delivery_address": "Colombo",
      "delivery_city": "Colombo",
      "delivery_country": "Sri Lanka",
      "custom_1": "",
      "custom_2": ""
    };

    setState(() {
      _isProcessing = true;
    });

    PayHere.startPayment(
      paymentObject,
      (paymentId) {
        // Success
        Navigator.of(context).pop(true);
      },
      (error) {
        // Failure
        Navigator.of(context).pop(false);
      },
      () {
        // Cancelled/dismissed
        Navigator.of(context).pop(false);
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
