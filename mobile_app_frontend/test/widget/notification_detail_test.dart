import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_frontend/data/models/notification_model.dart';
import 'package:mobile_app_frontend/presentation/pages/notification_detail_page.dart';

void main() {
  group('NotificationDetailPage Tests', () {
    late NotificationModel testNotification;

    setUp(() {
      testNotification = NotificationModel(
        notificationId: 1,
        customerId: 1,
        serviceReminderId: 100,
        title: 'Oil Change Due',
        message:
            'Your vehicle is due for an oil change service. Please schedule an appointment.',
        type: 'service_reminder',
        priority: 'High',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        vehicleRegistrationNumber: 'ABC123',
        vehicleBrand: 'Toyota',
        vehicleModel: 'Camry',
        serviceName: 'Oil Change Service',
        customerName: 'John Doe',
      );
    });

    testWidgets('should display notification details correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationDetailPage(notification: testNotification),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title is displayed
      expect(find.text('Oil Change Due'), findsOneWidget);

      // Verify message is displayed
      expect(
          find.text(
              'Your vehicle is due for an oil change service. Please schedule an appointment.'),
          findsOneWidget);

      // Verify priority is displayed
      expect(find.text('High'), findsWidgets);

      // Verify type is displayed
      expect(find.text('SERVICE_REMINDER'), findsOneWidget);
    });

    testWidgets('should display status indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationDetailPage(notification: testNotification),
        ),
      );

      await tester.pumpAndSettle();

      // Should show unread status for new notification
      expect(find.text('Unread'), findsOneWidget);
      expect(find.byIcon(Icons.mark_email_unread), findsOneWidget);
    });

    testWidgets('should display vehicle information when available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationDetailPage(notification: testNotification),
        ),
      );

      await tester.pumpAndSettle();

      // Verify vehicle registration is displayed
      expect(find.text('ABC123'), findsOneWidget);

      // Verify vehicle info is displayed
      expect(find.text('Toyota Camry'), findsOneWidget);
    });

    testWidgets('should display service information when available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationDetailPage(notification: testNotification),
        ),
      );

      await tester.pumpAndSettle();

      // Verify service name is displayed
      expect(find.text('Oil Change Service'), findsOneWidget);

      // Verify service reminder ID is displayed
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('should display customer information when available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationDetailPage(notification: testNotification),
        ),
      );

      await tester.pumpAndSettle();

      // Verify customer name is displayed
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('should have delete button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationDetailPage(notification: testNotification),
        ),
      );

      await tester.pumpAndSettle();

      // Should have delete icon in app bar
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should display read notification correctly',
        (WidgetTester tester) async {
      final readNotification = testNotification.copyWith(
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationDetailPage(notification: readNotification),
        ),
      );

      await tester.pumpAndSettle();

      // Should show read status
      expect(find.text('Read'), findsOneWidget);
      expect(find.byIcon(Icons.mark_email_read), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationDetailPage(notification: testNotification),
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Delete Notification'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this notification?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsWidgets);
    });

    testWidgets('should handle notification without optional fields',
        (WidgetTester tester) async {
      final minimalNotification = NotificationModel(
        customerId: 1,
        title: 'Simple Notification',
        message: 'This is a simple notification without optional fields.',
        type: 'general',
        priority: 'Low',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationDetailPage(notification: minimalNotification),
        ),
      );

      await tester.pumpAndSettle();

      // Should display basic information
      expect(find.text('Simple Notification'), findsOneWidget);
      expect(
          find.text('This is a simple notification without optional fields.'),
          findsOneWidget);
      expect(find.text('GENERAL'), findsOneWidget);
      expect(find.text('Low'), findsWidgets);
    });
  });
}
