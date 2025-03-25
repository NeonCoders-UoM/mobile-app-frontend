import 'package:flutter/material.dart';
import 'presentation/pages/appointment_page.dart'; // Import the new view page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppointmentPage(), // Navigate to the new AppointmentView page
    );
  }
}
