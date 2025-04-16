import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/pages/fuel_summary_page.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Service App',
      theme: ThemeData(
        primaryColor: AppColors.primary200,
        scaffoldBackgroundColor: AppColors.neutral600,
        cardColor: AppColors.neutral500,
      ),
      home: const FuelSummaryPage(),
    );
  }
}
