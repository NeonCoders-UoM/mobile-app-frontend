import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/appointment_card.dart';
// Import AppointmentCard component

class AppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'), // Page title
        backgroundColor: AppColors.neutral400, // App bar color
      ),
      backgroundColor: AppColors.neutral400, // Page background color
      body: Padding(
        padding: EdgeInsets.all(16), // Add spacing around the cards
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the cards
          children: [
            AppointmentCard(), // First card
            SizedBox(height: 16), // Space between cards
            AppointmentCard(), // Second card
            SizedBox(height: 16), // Space between cards
            AppointmentCard(), // Third card
          ],
        ),
      ),
    );
  }
}
