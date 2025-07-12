import 'package:mobile_app_frontend/core/services/reminder_api_service.dart';
import 'package:mobile_app_frontend/data/models/reminder_model.dart';

class ReminderRepository {
  // Get all reminders
  Future<List<ServiceReminderModel>> getAllReminders() async {
    try {
      return await ReminderApiService.getAllReminders();
    } catch (e) {
      throw Exception('Failed to fetch all reminders: $e');
    }
  }

  // Get reminders for a specific vehicle
  Future<List<ServiceReminderModel>> getVehicleReminders(int vehicleId) async {
    try {
      return await ReminderApiService.getVehicleReminders(vehicleId);
    } catch (e) {
      throw Exception('Failed to fetch vehicle reminders: $e');
    }
  }

  // Get upcoming reminders
  Future<List<ServiceReminderModel>> getUpcomingReminders({int? days}) async {
    try {
      return await ReminderApiService.getUpcomingReminders(days: days);
    } catch (e) {
      throw Exception('Failed to fetch upcoming reminders: $e');
    }
  }

  // Create a new reminder
  Future<ServiceReminderModel> createReminder(
      ServiceReminderModel reminder) async {
    try {
      return await ReminderApiService.createReminder(reminder);
    } catch (e) {
      throw Exception('Failed to create reminder: $e');
    }
  }

  // Update an existing reminder
  Future<void> updateReminder(
      int reminderId, ServiceReminderModel reminder) async {
    try {
      await ReminderApiService.updateReminder(reminderId, reminder);
    } catch (e) {
      throw Exception('Failed to update reminder: $e');
    }
  }

  // Delete a reminder
  Future<void> deleteReminder(int reminderId) async {
    try {
      await ReminderApiService.deleteReminder(reminderId);
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }

  // Get a specific reminder by ID
  Future<ServiceReminderModel> getReminder(int reminderId) async {
    try {
      return await ReminderApiService.getReminder(reminderId);
    } catch (e) {
      throw Exception('Failed to fetch reminder: $e');
    }
  }
}
