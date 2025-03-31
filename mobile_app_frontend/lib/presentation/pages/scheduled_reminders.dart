import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/add_reminders_button.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/reminder_details_dialog.dart';
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
      'nextDue': '15,000 km or in 8 months',
      'mileageInterval': '15,000km',
      'timeInterval': '6 months',
      'lastServiceDate': '01/02/2025',
    },
    {
      'title': 'Tire Rotation',
      'description': 'Next: 20,000 km or in 6 months',
      'status': ServiceStatus.overdue,
      'nextDue': '20,000 km or in 6 months',
      'mileageInterval': '20,000km',
      'timeInterval': '6 months',
      'lastServiceDate': '01/01/2025',
    },
    {
      'title': 'Service Type',
      'description': 'Next Due',
      'status': ServiceStatus.completed,
      'nextDue': 'Next Due',
      'mileageInterval': '10,000km',
      'timeInterval': '12 months',
      'lastServiceDate': '01/03/2025',
    },
    {
      'title': 'Service Type',
      'description': 'Next Due',
      'status': ServiceStatus.scheduled,
      'nextDue': 'Next Due',
      'mileageInterval': '10,000km',
      'timeInterval': '12 months',
      'lastServiceDate': '01/04/2025',
    },
    {
      'title': 'Service Type',
      'description': 'Next Due',
      'status': ServiceStatus.inProgress,
      'nextDue': 'Next Due',
      'mileageInterval': '10,000km',
      'timeInterval': '12 months',
      'lastServiceDate': '01/05/2025',
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
            const VehicleHeader(
              vehicleName: 'Mustang 1977',
              vehicleId: 'AB89B395',
            ),
            const SizedBox(height: 16.0),
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ReminderDetailsDialog(
                        title: reminder['title'],
                        nextDue: reminder['nextDue'],
                        status: reminder['status'],
                        mileageInterval: reminder['mileageInterval'],
                        timeInterval: reminder['timeInterval'],
                        lastServiceDate: reminder['lastServiceDate'],
                        onEdit: () {
                          Navigator.pop(context);
                        },
                        onDelete: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
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
