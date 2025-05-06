import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/costestimate_page.dart';
import 'package:mobile_app_frontend/presentation/pages/servicecenter_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VehicleDetailsPage()
    );
  }
}



