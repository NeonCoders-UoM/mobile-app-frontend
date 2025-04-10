import 'package:flutter/material.dart';
import 'presentation/pages/appointment_page.dart';
import 'presentation/pages/feedback_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FeedbackPage(), // Navigate to the new AppointmentView page
    );
  }
}
