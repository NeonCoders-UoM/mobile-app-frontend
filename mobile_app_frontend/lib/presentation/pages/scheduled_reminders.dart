import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/add_reminders_button.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/reminder_details_dialog.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/service_reminder_card.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';
import 'package:mobile_app_frontend/presentation/pages/set_reminder_page.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  _RemindersPageState createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  // Make the reminders list mutable
  List<Map<String, dynamic>> reminders = [
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
                onPressed: () async {
                  // Navigate to SetReminderPage and wait for the result
                  final newReminder = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SetReminderPage()),
                  );
                  if (newReminder != null) {
                    setState(() {
                      reminders.add(newReminder);
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 32.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return ServiceReminderCard(
                  title: reminder['title'] ?? 'Untitled',
                  description: reminder['description'] ?? 'No description',
                  status: reminder['status'] ?? ServiceStatus.upcoming,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ReminderDetailsDialog(
                        title: reminder['title'],
                        nextDue: reminder['nextDue'],
                        status: reminder['status'] ?? ServiceStatus.upcoming,
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
              separatorBuilder: (context, index) => const SizedBox(height: 4.0),
            ),
          ],
        ),
      ),
    );
  }
}
