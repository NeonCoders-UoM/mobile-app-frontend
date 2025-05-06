import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/appointment_card.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/appointmentdateselection_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage( {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Appointments',
        showTitle: true,
        onBackPressed: () => {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const VehicleDetailsPage()))
        },
      ),
      backgroundColor: AppColors.neutral400,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppointmentCard(
              servicecenterName: "Janaka Motors",
              date: "Sat, Feb, 2025",
            ),
            SizedBox(height: 24),
            AppointmentCard(
              servicecenterName: "Janaka Motors",
              date: "Sat, Feb, 2025",
            ),
            SizedBox(height: 24),
            AppointmentCard(
              servicecenterName: "Janaka Motors",
              date: "Sat, Feb, 2025",
            ),
            SizedBox(height: 24),
            AppointmentCard(
              servicecenterName: "Janaka Motors",
              date: "Sat, Feb, 2025",
            ),
          ],
          
        ),
      ),
      floatingActionButton: FloatingActionButton(
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentdateselectionPage()));
    },
    backgroundColor: AppColors.neutral150, // or your preferred color
    child: const Icon(Icons.add),
  ),
    );
  }
}
