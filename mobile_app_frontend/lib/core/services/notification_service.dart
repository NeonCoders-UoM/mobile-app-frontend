import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static Future<void> sendNotificationToBackend({
    required int customerId,
    required Map<String, dynamic> notificationData,
    required String token,
  }) async {
    final url = Uri.parse(
        'http://localhost:5039/api/Notifications'); // <-- Replace with your backend URL
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(notificationData),
    );
    if (response.statusCode != 201) {
      // Optionally handle error
      print('Failed to create backend notification: \\${response.body}');
    }
  }

  static Future<void> deleteNotificationFromBackend({
    required int notificationId,
    required String token,
  }) async {
    final url = Uri.parse(
        'http://localhost:5039/api/Notifications/$notificationId'); // <-- Replace with your backend URL
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      // Optionally handle error
      print('Failed to delete backend notification: \\${response.body}');
      throw Exception('Failed to delete notification');
    }
  }

  static Future<void> markNotificationAsRead({
    required int notificationId,
    required String token,
  }) async {
    final url = Uri.parse(
        'http://localhost:5039/api/Notifications/$notificationId/MarkAsRead');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      print('Failed to mark notification as read: \\${response.body}');
      throw Exception('Failed to mark notification as read');
    }
  }

  static Future<void> markAllNotificationsAsRead({
    required int customerId,
    required String token,
  }) async {
    final url = Uri.parse(
        'http://localhost:5039/api/Notifications/Customer/$customerId/MarkAllAsRead');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      print('Failed to mark all notifications as read: \\${response.body}');
      throw Exception('Failed to mark all notifications as read');
    }
  }

  static Future<void> generateNotificationsFromServiceReminders({
    required String token,
  }) async {
    final url = Uri.parse(
        'http://localhost:5039/api/Notifications/GenerateFromServiceReminders');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      print(
          'Failed to generate notifications from service reminders: \\${response.body}');
      throw Exception(
          'Failed to generate notifications from service reminders');
    }
  }
}
