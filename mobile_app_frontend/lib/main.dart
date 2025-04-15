import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/pages/service_history_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Service History',
      theme: ThemeData.dark(),
      home: const ServiceHistoryPage(),
    );
  }
}
