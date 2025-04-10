import 'package:flutter/material.dart';
import 'presentation/pages/appointment_page.dart';
import 'presentation/pages/costestimate_page.dart'; // Import the new view page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CostEstimatePage(), // Navigate to the new AppointmentView page
    );
  }
}
