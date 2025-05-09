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
  List<Map<String, dynamic>> reminders = [
    {
      'title': 'Oil Change',
      'description': 'Next: in 8 months',
      'status': ServiceStatus.upcoming,
      'nextDue': 'in 8 months',
      'timeInterval': '6 months',
      'lastServiceDate': '01/02/2025',
      'mileageInterval': 'Not specified',
      'notifyPeriod': '7 days before',
    },
    {
      'title': 'Tire Rotation',
      'description': 'Next: in 6 months',
      'status': ServiceStatus.overdue,
      'nextDue': 'in 6 months',
      'timeInterval': '6 months',
      'lastServiceDate': '01/01/2025',
      'mileageInterval': 'Not specified',
      'notifyPeriod': '7 days before',
    },
    {
      'title': 'Service Type',
      'description': 'Next: in 12 months',
      'status': ServiceStatus.completed,
      'nextDue': 'in 12 months',
      'timeInterval': '12 months',
      'lastServiceDate': '01/03/2025',
      'mileageInterval': 'Not specified',
      'notifyPeriod': '7 days before',
    },
    {
      'title': 'Service Type',
      'description': 'Next: in 12 months',
      'status': ServiceStatus.scheduled,
      'nextDue': 'in 12 months',
      'timeInterval': '12 months',
      'lastServiceDate': '01/04/2025',
      'mileageInterval': 'Not specified',
      'notifyPeriod': '7 days before',
    },
    {
      'title': 'Service Type',
      'description': 'Next: in 12 months',
      'status': ServiceStatus.inProgress,
      'nextDue': 'in 12 months',
      'timeInterval': '12 months',
      'lastServiceDate': '01/05/2025',
      'mileageInterval': 'Not specified',
      'notifyPeriod': '7 days before',
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
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: AddReminderButton(
                onPressed: () async {
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
                  onTap: () async {
                    // Show the dialog and wait for a result
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => ReminderDetailsDialog(
                        title: reminder['title'],
                        nextDue: reminder['nextDue'],
                        status: reminder['status'] ?? ServiceStatus.upcoming,
                        timeInterval: reminder['timeInterval'],
                        lastServiceDate: reminder['lastServiceDate'],
                        reminder: reminder,
                        index: index,
                        onEdit: () {},
                        onDelete: () {
                          // Implement delete functionality
                          setState(() {
                            reminders.removeAt(index);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );

                    // If a result is returned (from EditReminderPage), update the reminder
                    if (result != null) {
                      setState(() {
                        final updatedReminder =
                            result['reminder'] as Map<String, dynamic>;
                        final updatedIndex = result['index'] as int;
                        reminders[updatedIndex] = updatedReminder;
                      });
                    }
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
