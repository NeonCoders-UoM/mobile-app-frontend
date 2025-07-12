import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/reminder_model.dart';
import 'package:mobile_app_frontend/data/repositories/reminder_repository.dart';

void main() {
  group('Reminder Integration Tests', () {
    late ReminderRepository repository;

    setUp(() {
      repository = ReminderRepository();
    });

    test('should create and retrieve a service reminder', () async {
      // Create a test reminder
      final testReminder = ServiceReminderModel(
        vehicleId: ApiConfig.defaultVehicleId,
        serviceId: 1, // Assuming service ID 1 exists in your backend
        reminderDate: DateTime.now().add(const Duration(days: 30)),
        intervalMonths: 6,
        notifyBeforeDays: 7,
        notes: 'Test reminder for integration',
        isActive: true,
      );

      try {
        // Test creation
        final createdReminder = await repository.createReminder(testReminder);
        expect(createdReminder.serviceReminderId, isNotNull);
        expect(createdReminder.vehicleId, equals(testReminder.vehicleId));
        expect(createdReminder.serviceName,
            isNotNull); // Should be populated by backend

        // Test retrieval by vehicle
        final vehicleReminders =
            await repository.getVehicleReminders(ApiConfig.defaultVehicleId);
        expect(vehicleReminders.isNotEmpty, isTrue);

        // Find our created reminder
        final foundReminder = vehicleReminders.firstWhere(
          (r) => r.serviceReminderId == createdReminder.serviceReminderId,
          orElse: () => throw Exception(
              'Created reminder not found in vehicle reminders'),
        );
        expect(foundReminder.notes, equals(testReminder.notes));

        // Test upcoming reminders
        final upcomingReminders =
            await repository.getUpcomingReminders(days: 60);
        expect(
            upcomingReminders.any((r) =>
                r.serviceReminderId == createdReminder.serviceReminderId),
            isTrue);

        // Clean up - delete the test reminder
        await repository.deleteReminder(createdReminder.serviceReminderId!);

        print(
            '✓ Integration test passed: Create, retrieve, and delete reminder');
      } catch (e) {
        print('✗ Integration test failed: $e');
        print(
            'This might be expected if the backend is not running or not configured properly.');
        print(
            'Make sure your .NET backend is running on ${ApiConfig.currentBaseUrl}');
        rethrow;
      }
    });

    test('should handle backend errors gracefully', () async {
      try {
        // Try to get reminders for a non-existent vehicle
        await repository.getVehicleReminders(999999);
        // If we get here without an exception, the backend might return empty list
        print(
            '✓ Backend returned empty list for non-existent vehicle (graceful handling)');
      } catch (e) {
        // This is expected behavior
        expect(e.toString().contains('Failed to fetch'), isTrue);
        print('✓ Backend properly returns error for non-existent vehicle');
      }
    });

    test('should validate API configuration', () {
      // Test that API configuration is properly set up
      expect(ApiConfig.currentBaseUrl, isNotNull);
      expect(ApiConfig.currentBaseUrl.isNotEmpty, isTrue);
      expect(ApiConfig.defaultVehicleId, isA<int>());

      // Test URL generation
      final allRemindersUrl = ApiConfig.getAllRemindersUrl();
      final vehicleRemindersUrl = ApiConfig.getVehicleRemindersUrl(1);
      final upcomingRemindersUrl = ApiConfig.getUpcomingRemindersUrl();

      expect(allRemindersUrl.contains('/ServiceReminders'), isTrue);
      expect(
          vehicleRemindersUrl.contains('/ServiceReminders/Vehicle/1'), isTrue);
      expect(
          upcomingRemindersUrl.contains('/ServiceReminders/Upcoming'), isTrue);

      print('✓ API configuration validated');
    });
  });
}
