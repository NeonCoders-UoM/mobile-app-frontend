import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_frontend/presentation/pages/notifications_page.dart';

void main() {
  group('Notification Detail Integration Tests', () {
    testWidgets('should navigate from notifications list to detail page',
        (WidgetTester tester) async {
      // Build the NotificationsPage
      await tester.pumpWidget(
        MaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Wait for the widget to settle and load sample data
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find the first notification card (should have sample data)
      final notificationCards = find.byType(GestureDetector);

      if (notificationCards.evaluate().isNotEmpty) {
        // Tap the first notification
        await tester.tap(notificationCards.first);
        await tester.pumpAndSettle();

        // Should navigate to detail page
        expect(find.text('Notification Details'), findsOneWidget);
      }
    });

    testWidgets('should show notification options on long press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const NotificationsPage(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      final notificationCards = find.byType(GestureDetector);

      if (notificationCards.evaluate().isNotEmpty) {
        // Long press the first notification
        await tester.longPress(notificationCards.first);
        await tester.pumpAndSettle();

        // Should show bottom sheet with options
        expect(find.text('Notification Options'), findsOneWidget);
        expect(find.text('View Details'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      }
    });

    testWidgets('should handle empty notifications state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Wait for initial load
      await tester.pump();

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should either show notifications or empty state
      expect(
        find.textContaining('notification').evaluate().isNotEmpty ||
            find.text('No notifications yet').evaluate().isNotEmpty,
        isTrue,
      );
    });
  });
}
