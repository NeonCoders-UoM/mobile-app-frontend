import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/add_reminders_button.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/service_reminder_card.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({Key? key}) : super(key: key);

  // Sample data (replace with actual data source)
  final List<Map<String, dynamic>> reminders = const [
    {
      'title': 'Oil Change',
      'description': 'Next: 15,000 km or in 8 months',
      'status': ServiceStatus.upcoming,
    },
    {
      'title': 'Tire Rotation',
      'description': 'Next: 20,000 km or in 6 months',
      'status': ServiceStatus.overdue,
    },
    {
      'title': 'Service Type',
      'description': 'Next Due',
      'status': ServiceStatus.completed,
    },
    {
      'title': 'Service Type',
      'description': 'Next Due',
      'status': ServiceStatus.scheduled,
    },
    {
      'title': 'Service Type',
      'description': 'Next Due',
      'status': ServiceStatus.inProgress,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: const CustomAppBar(
        title: 'Reminders',
        showTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32.0),
            const VehicleHeader(
              vehicleName: 'Mustang 1977',
              vehicleId: 'AB89B395',
            ),
            const SizedBox(height: 48.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: AddReminderButton(
                onPressed: () {
                  // Add your desired functionality here
                },
              ),
            ),
            const SizedBox(height: 32.0), // Padding between button and list
            ListView.separated(
              shrinkWrap: true, // Needed inside SingleChildScrollView
              physics:
                  const NeverScrollableScrollPhysics(), // Disable ListView's scrolling
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return ServiceReminderCard(
                  title: reminder['title'],
                  description: reminder['description'],
                  status: reminder['status'],
                  onTap: () {},
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 4.0), // 4px padding between items
            ),
          ],
        ),
      ),
    );
  }
}
