import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/reminder_details_dialog.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/service_reminder_card.dart';

void main() {
  group('Reminder Details Dialog UI Tests', () {
    testWidgets('should handle very long service names without overflow',
        (WidgetTester tester) async {
      // Create a test reminder with a very long service name
      final testReminder = {
        'serviceReminderId': 1,
        'vehicleId': 1,
        'serviceId': 1,
        'notes':
            'This is a very long service name that should not cause any overflow issues in the dialog layout and should be properly truncated',
        'reminderDate': '2024-12-31',
        'intervalMonths': 6,
        'notifyBeforeDays': 7,
        'timeInterval': '6 months',
        'mileageInterval': '10000 km',
        'lastServiceDate': '2024-06-30',
      };

      // Build the dialog
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ReminderDetailsDialog(
                      title: testReminder['notes'] as String,
                      nextDue: '2024-12-31',
                      status: ServiceStatus.upcoming,
                      mileageInterval: '10000 km',
                      timeInterval: '6 months',
                      lastServiceDate: '2024-06-30',
                      reminder: testReminder,
                      index: 0,
                      onEdit: () {},
                      onDelete: () {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed
      expect(find.byType(ReminderDetailsDialog), findsOneWidget);

      // Verify that the long service name is displayed (should be truncated)
      expect(find.textContaining('This is a very long service name'),
          findsOneWidget);

      // Check that there are no overflow errors
      expect(tester.takeException(), isNull);

      // Verify the dialog has the expected structure
      expect(find.text('NEXT DUE:'), findsOneWidget);
      expect(find.text('STATUS:'), findsOneWidget);
      expect(find.text('EDIT'), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);
    });

    testWidgets('should display all reminder details correctly',
        (WidgetTester tester) async {
      final testReminder = {
        'serviceReminderId': 1,
        'vehicleId': 1,
        'serviceId': 1,
        'notes': 'Oil Change',
        'reminderDate': '2024-12-31',
        'intervalMonths': 6,
        'notifyBeforeDays': 7,
        'timeInterval': '6 months',
        'mileageInterval': '10000 km',
        'lastServiceDate': '2024-06-30',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ReminderDetailsDialog(
                      title: 'Oil Change',
                      nextDue: '2024-12-31',
                      status: ServiceStatus.upcoming,
                      mileageInterval: '10000 km',
                      timeInterval: '6 months',
                      lastServiceDate: '2024-06-30',
                      reminder: testReminder,
                      index: 0,
                      onEdit: () {},
                      onDelete: () {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify all details are displayed
      expect(find.text('Oil Change'), findsOneWidget);
      expect(find.text('NEXT DUE:'), findsOneWidget);
      expect(find.text('STATUS:'), findsOneWidget);
      expect(find.text('MILEAGE INTERVAL:'), findsOneWidget);
      expect(find.text('TIME INTERVAL:'), findsOneWidget);
      expect(find.text('LAST SERVICE DATE:'), findsOneWidget);
    });
  });
}
