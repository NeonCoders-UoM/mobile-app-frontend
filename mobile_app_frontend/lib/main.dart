import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/document-card.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/successful-message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(
            255, 49, 48, 48), // Optional: to see your card clearly
        body: Center(
          child: SuccessfulMessage(),
        ),
      ),
    );
  }
}
