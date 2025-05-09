import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/notification_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  // Sample data for notifications
  static final List<Map<String, String>> _notifications = [
    {
      'title': 'Oil Change',
      'description':
          'Replacing engine oil keeps the engine lubricated and prevents wear.',
      'time': '5 minutes ago',
    },
    {
      'title': 'Oil Filter Replace...',
      'description': 'Removes dirt and debris from the oil.',
      'time': '3 hours ago',
    },
    {
      'title': 'Air Filter Replace...',
      'description':
          'Ensures clean air enters the engine for better performance.',
      'time': 'Yesterday',
    },
    {
      'title': 'Coolant Check',
      'description': 'Keeps the air inside the car fresh and free of dust.',
      'time': 'Yesterday',
    },
    {
      'title': 'Oil Change',
      'description':
          'Ensures clean air enters the engine for better performance.',
      'time': '3. Feb',
    },
    {
      'title': 'Brake Fluid Replace...',
      'description':
          'Replacing engine oil keeps the engine lubricated and prevents wear.',
      'time': '12. Feb',
    },
    {
      'title': 'Coolant Check',
      'description':
          'Replacing engine oil keeps the engine lubricated and prevents wear.',
      'time': '1. Jan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.neutral400, // Match the dark background from the image
      appBar: const CustomAppBar(
        title: 'Notifications',
        showTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return NotificationCard(
            title: notification['title']!,
            description: notification['description']!,
            time: notification['time']!,
          );
        },
      ),
    );
  }
}
