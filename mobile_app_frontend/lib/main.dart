import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/pages/add_service_documents_page.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/costestimate_page.dart';
import 'package:mobile_app_frontend/presentation/pages/external-service-history_page.dart';
import 'package:mobile_app_frontend/presentation/pages/home_page.dart';
import 'package:mobile_app_frontend/presentation/pages/scheduled_reminders.dart';
import 'package:mobile_app_frontend/presentation/pages/servicecenter_page.dart';
import 'package:mobile_app_frontend/presentation/pages/set_reminder_page.dart';
import 'package:mobile_app_frontend/presentation/pages/start_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicle_deleted_page.dart';
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
      home: VehicleDetailsPage(),
    );
  }
}
