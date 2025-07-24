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
}
