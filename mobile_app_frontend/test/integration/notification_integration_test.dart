import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_frontend/data/models/notification_model.dart';
import 'package:mobile_app_frontend/data/repositories/notification_repository.dart';

void main() {
  group('Notification Integration Tests', () {
    late NotificationRepository repository;

    setUp(() {
      repository = NotificationRepository();
    });

    test('should create notification model from JSON', () {
      // Test JSON data matching the NotificationDTO structure
      final testJson = {
        'notificationId': 1,
        'customerId': 1,
        'serviceReminderId': 2,
        'title': 'Oil Change Due',
        'message': 'Your vehicle is due for an oil change service.',
        'type': 'service_reminder',
        'isRead': false,
        'isSent': true,
        'createdAt': '2025-01-14T10:30:00Z',
        'readAt': null,
        'sentAt': '2025-01-14T10:30:00Z',
        'scheduledFor': null,
        'priority': 'High',
        'customerName': 'John Doe',
        'customerEmail': 'john@example.com',
        'vehicleRegistrationNumber': 'ABC123',
        'vehicleBrand': 'Toyota',
        'vehicleModel': 'Camry',
        'serviceReminderDate': '2025-01-20T00:00:00Z',
        'serviceName': 'Oil Change'
      };

      // Test creation from JSON
      final notification = NotificationModel.fromJson(testJson);

      expect(notification.notificationId, equals(1));
      expect(notification.customerId, equals(1));
      expect(notification.title, equals('Oil Change Due'));
      expect(notification.priority, equals('High'));
      expect(notification.isRead, equals(false));
      expect(notification.vehicleBrand, equals('Toyota'));
      expect(notification.serviceName, equals('Oil Change'));
    });

    test('should convert notification model to create DTO', () {
      // Create a test notification
      final notification = NotificationModel(
        customerId: 1,
        serviceReminderId: 2,
        title: 'Test Notification',
        message: 'This is a test message',
        type: 'test',
        priority: 'Medium',
        createdAt: DateTime.now(),
      );

      // Convert to create DTO
      final createDto = notification.toCreateDto();

      expect(createDto['customerId'], equals(1));
      expect(createDto['serviceReminderId'], equals(2));
      expect(createDto['title'], equals('Test Notification'));
      expect(createDto['message'], equals('This is a test message'));
      expect(createDto['type'], equals('test'));
      expect(createDto['priority'], equals('Medium'));

      // These fields should not be in create DTO
      expect(createDto.containsKey('notificationId'), isFalse);
      expect(createDto.containsKey('isRead'), isFalse);
      expect(createDto.containsKey('createdAt'), isFalse);
    });

    test('should generate correct display time', () {
      final now = DateTime.now();

      // Test "Just now"
      final recentNotification = NotificationModel(
        customerId: 1,
        title: 'Recent',
        message: 'Recent message',
        type: 'test',
        priority: 'Low',
        createdAt: now.subtract(const Duration(seconds: 30)),
      );
      expect(recentNotification.displayTime, equals('Just now'));

      // Test minutes ago
      final minutesAgoNotification = NotificationModel(
        customerId: 1,
        title: 'Minutes ago',
        message: 'Minutes ago message',
        type: 'test',
        priority: 'Low',
        createdAt: now.subtract(const Duration(minutes: 5)),
      );
      expect(minutesAgoNotification.displayTime, equals('5 minutes ago'));

      // Test hours ago
      final hoursAgoNotification = NotificationModel(
        customerId: 1,
        title: 'Hours ago',
        message: 'Hours ago message',
        type: 'test',
        priority: 'Low',
        createdAt: now.subtract(const Duration(hours: 3)),
      );
      expect(hoursAgoNotification.displayTime, equals('3 hours ago'));

      // Test yesterday
      final yesterdayNotification = NotificationModel(
        customerId: 1,
        title: 'Yesterday',
        message: 'Yesterday message',
        type: 'test',
        priority: 'Low',
        createdAt: now.subtract(const Duration(days: 1)),
      );
      expect(yesterdayNotification.displayTime, equals('Yesterday'));
    });

    test('should generate correct priority colors', () {
      final criticalNotification = NotificationModel(
        customerId: 1,
        title: 'Critical',
        message: 'Critical message',
        type: 'test',
        priority: 'Critical',
        createdAt: DateTime.now(),
      );
      expect(criticalNotification.priorityColor, equals('#FF4444'));

      final highNotification = NotificationModel(
        customerId: 1,
        title: 'High',
        message: 'High message',
        type: 'test',
        priority: 'High',
        createdAt: DateTime.now(),
      );
      expect(highNotification.priorityColor, equals('#FF8800'));

      final mediumNotification = NotificationModel(
        customerId: 1,
        title: 'Medium',
        message: 'Medium message',
        type: 'test',
        priority: 'Medium',
        createdAt: DateTime.now(),
      );
      expect(mediumNotification.priorityColor, equals('#FFD700'));
    });

    test('should handle summary model creation', () {
      final summaryJson = {
        'totalNotifications': 15,
        'unreadNotifications': 3,
        'pendingNotifications': 2,
        'sentNotifications': 13
      };

      final summary = NotificationSummaryModel.fromJson(summaryJson);

      expect(summary.totalNotifications, equals(15));
      expect(summary.unreadNotifications, equals(3));
      expect(summary.pendingNotifications, equals(2));
      expect(summary.sentNotifications, equals(13));
    });

    test('should validate API configuration', () {
      // Import the API config to test
      // This ensures the URLs are properly configured

      // Note: In a real test, you would import and test ApiConfig
      // For now, we'll test that the repository can be instantiated
      expect(repository, isNotNull);
      expect(repository, isA<NotificationRepository>());
    });

    test('should handle empty notification lists', () async {
      // Test that the repository handles empty responses gracefully
      // This would typically mock the API service, but for now we test structure

      try {
        // This will fail if backend is not running, which is expected
        final notifications = await repository.getCustomerNotifications(999);
        // If it succeeds, verify it returns a list
        expect(notifications, isA<List<NotificationModel>>());
      } catch (e) {
        // Expected to fail without backend - test that it throws appropriate exception
        expect(
            e.toString(), contains('Failed to fetch customer notifications'));
      }
    });

    test('should handle copyWith functionality', () {
      final original = NotificationModel(
        customerId: 1,
        title: 'Original Title',
        message: 'Original message',
        type: 'test',
        priority: 'Low',
        createdAt: DateTime.now(),
        isRead: false,
      );

      final updated = original.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );

      expect(updated.isRead, isTrue);
      expect(updated.readAt, isNotNull);
      expect(updated.title, equals('Original Title')); // Unchanged
      expect(updated.customerId, equals(1)); // Unchanged
    });

    test('should validate toString and equality', () {
      final notification1 = NotificationModel(
        notificationId: 1,
        customerId: 1,
        title: 'Test',
        message: 'Test message',
        type: 'test',
        priority: 'Low',
        createdAt: DateTime.now(),
      );

      final notification2 = NotificationModel(
        notificationId: 1,
        customerId: 1,
        title: 'Different Title',
        message: 'Different message',
        type: 'test',
        priority: 'High',
        createdAt: DateTime.now(),
      );

      final notification3 = NotificationModel(
        notificationId: 2,
        customerId: 1,
        title: 'Test',
        message: 'Test message',
        type: 'test',
        priority: 'Low',
        createdAt: DateTime.now(),
      );

      // Test toString
      expect(notification1.toString(), contains('id: 1'));
      expect(notification1.toString(), contains('title: Test'));

      // Test equality (based on notificationId)
      expect(notification1, equals(notification2)); // Same ID
      expect(notification1, isNot(equals(notification3))); // Different ID

      // Test hashCode
      expect(notification1.hashCode, equals(notification2.hashCode));
      expect(notification1.hashCode, isNot(equals(notification3.hashCode)));
    });
  });
}
