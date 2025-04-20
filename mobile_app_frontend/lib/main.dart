import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/document-card.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/payment_method_option.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[200], // Optional: to see your card clearly
        body: Center(
          child: PaymentMethodOption(
            label: 'Visa',
            iconPath: 'assets/icons/Visa.png', // Replace with your asset path
            onTap: () {
              // Handle tap event
              print('Payment method tapped!');
            },
          ),
        ),
      ),
    );
  }
}
