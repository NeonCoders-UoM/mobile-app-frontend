import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/appointment_card.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';

class AppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Appointments',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppointmentCard(
              garageName: "Janaka Motors",
              date: "Sat, Feb, 2025",
              onInvoicePressed: () {
                print("Invoice tapped!");
              },
            ),
            SizedBox(height: 24),
            AppointmentCard(
              garageName: "Janaka Motors",
              date: "Sat, Feb, 2025",
              onInvoicePressed: () {
                print("Invoice tapped!");
              },
            ),
            SizedBox(height: 24),
            AppointmentCard(
              garageName: "Janaka Motors",
              date: "Sat, Feb, 2025",
              onInvoicePressed: () {
                print("Invoice tapped!");
              },
            ),
            SizedBox(height: 24),
            AppointmentCard(
              garageName: "Janaka Motors",
              date: "Sat, Feb, 2025",
              onInvoicePressed: () {
                print("Invoice tapped!");
              },
            ),
          ],
        ),
      ),
    );
  }
}
