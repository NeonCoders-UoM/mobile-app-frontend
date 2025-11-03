import 'package:mobile_app_frontend/core/services/reminder_api_service.dart';
import 'package:mobile_app_frontend/data/models/reminder_model.dart';

class ReminderRepository {
  // Get all reminders
  Future<List<ServiceReminderModel>> getAllReminders({String? token}) async {
    try {
      return await ReminderApiService.getAllReminders(token: token);
    } catch (e) {
      throw Exception('Failed to fetch all reminders: $e');
    }
  }

  // Get reminders for a specific vehicle
  Future<List<ServiceReminderModel>> getVehicleReminders(int vehicleId,
      {String? token}) async {
    try {
      return await ReminderApiService.getVehicleReminders(vehicleId,
          token: token);
    } catch (e) {
      throw Exception('Failed to fetch vehicle reminders: $e');
    }
  }

  // Get upcoming reminders
  Future<List<ServiceReminderModel>> getUpcomingReminders(
      {int? days, String? token}) async {
    try {
      return await ReminderApiService.getUpcomingReminders(
          days: days, token: token);
    } catch (e) {
      throw Exception('Failed to fetch upcoming reminders: $e');
    }
  }

  // Create a new reminder
  Future<ServiceReminderModel> createReminder(ServiceReminderModel reminder,
      {String? token}) async {
    try {
      return await ReminderApiService.createReminder(reminder, token: token);
    } catch (e) {
      throw Exception('Failed to create reminder: $e');
    }
  }

  // Update an existing reminder
  Future<void> updateReminder(int reminderId, ServiceReminderModel reminder,
      {String? token}) async {
    try {
      await ReminderApiService.updateReminder(reminderId, reminder,
          token: token);
    } catch (e) {
      throw Exception('Failed to update reminder: $e');
    }
  }

  // Delete a reminder
  Future<void> deleteReminder(int reminderId, {String? token}) async {
    try {
      await ReminderApiService.deleteReminder(reminderId, token: token);
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }

  // Get a specific reminder by ID
  Future<ServiceReminderModel> getReminder(int reminderId,
      {String? token}) async {
    try {
      return await ReminderApiService.getReminder(reminderId, token: token);
    } catch (e) {
      throw Exception('Failed to fetch reminder: $e');
    }
  }
}
