import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/document-card.dart';

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
          child: DocumentCard(text: 'fdkjfdf'),
        ),
      ),
    );
  }
}
