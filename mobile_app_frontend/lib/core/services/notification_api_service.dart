import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/notification_model.dart';

class NotificationApiService {
  // Headers for API requests
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Add authorization header when you implement authentication
        // 'Authorization': 'Bearer ${AuthService.getToken()}',
      };

  // Helper method to handle CORS and other HTTP errors
  static Exception _handleHttpError(int statusCode, String responseBody) {
    switch (statusCode) {
      case 404:
        return Exception('Resource not found (404)');
      case 400:
        return Exception('Bad request (400): $responseBody');
      case 401:
        return Exception('Unauthorized (401): Please check authentication');
      case 403:
        return Exception('Forbidden (403): Access denied');
      case 500:
        return Exception('Internal server error (500): $responseBody');
      default:
        return Exception('HTTP Error ($statusCode): $responseBody');
    }
  }

  // Get all notifications
  static Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getAllNotificationsUrl()),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        // Debug: Print the response structure
        print('getAllNotifications Response type: ${responseBody.runtimeType}');

        // Handle different response formats
        List<dynamic> jsonList;
        if (responseBody is List) {
          jsonList = responseBody;
        } else if (responseBody is Map<String, dynamic>) {
          // If the response is wrapped in an object, try to extract the list
          if (responseBody.containsKey('data')) {
            jsonList = responseBody['data'] as List<dynamic>;
          } else if (responseBody.containsKey('notifications')) {
            jsonList = responseBody['notifications'] as List<dynamic>;
          } else {
            // Single object response, wrap in a list
            jsonList = [responseBody];
          }
        } else {
          throw Exception(
              'Unexpected response format: ${responseBody.runtimeType}');
        }

        return jsonList.map((json) {
          try {
            if (json is Map<String, dynamic>) {
              return NotificationModel.fromJson(json);
            } else {
              throw Exception('Invalid JSON item type: ${json.runtimeType}');
            }
          } catch (e) {
            print('Error parsing notification JSON: $e');
            print('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in getAllNotifications: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get notifications for a specific customer
  static Future<List<NotificationModel>> getCustomerNotifications(
      int customerId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getCustomerNotificationsUrl(customerId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        // Debug: Print the response structure
        print(
            'getCustomerNotifications Response type: ${responseBody.runtimeType}');

        // Handle different response formats
        List<dynamic> jsonList;
        if (responseBody is List) {
          jsonList = responseBody;
        } else if (responseBody is Map<String, dynamic>) {
          // If the response is wrapped in an object, try to extract the list
          if (responseBody.containsKey('data')) {
            jsonList = responseBody['data'] as List<dynamic>;
          } else if (responseBody.containsKey('notifications')) {
            jsonList = responseBody['notifications'] as List<dynamic>;
          } else {
            // Single object response, wrap in a list
            jsonList = [responseBody];
          }
        } else {
          throw Exception(
              'Unexpected response format: ${responseBody.runtimeType}');
        }

        return jsonList.map((json) {
          try {
            if (json is Map<String, dynamic>) {
              return NotificationModel.fromJson(json);
            } else {
              throw Exception('Invalid JSON item type: ${json.runtimeType}');
            }
          } catch (e) {
            print('Error parsing notification JSON: $e');
            print('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in getCustomerNotifications: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get unread notifications for a customer
  static Future<List<NotificationModel>> getCustomerUnreadNotifications(
      int customerId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getCustomerUnreadNotificationsUrl(customerId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        // Debug: Print the response structure
        print(
            'getCustomerUnreadNotifications Response type: ${responseBody.runtimeType}');

        // Handle different response formats
        List<dynamic> jsonList;
        if (responseBody is List) {
          jsonList = responseBody;
        } else if (responseBody is Map<String, dynamic>) {
          // If the response is wrapped in an object, try to extract the list
          if (responseBody.containsKey('data')) {
            jsonList = responseBody['data'] as List<dynamic>;
          } else {
            // Single object response, wrap in a list
            jsonList = [responseBody];
          }
        } else {
          throw Exception(
              'Unexpected response format: ${responseBody.runtimeType}');
        }

        return jsonList.map((json) {
          try {
            if (json is Map<String, dynamic>) {
              return NotificationModel.fromJson(json);
            } else {
              throw Exception('Invalid JSON item type: ${json.runtimeType}');
            }
          } catch (e) {
            print('Error parsing notification JSON: $e');
            print('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in getCustomerUnreadNotifications: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get notification summary for a customer
  static Future<NotificationSummaryModel> getNotificationSummary(
      int customerId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getNotificationSummaryUrl(customerId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);
        print(
            'getNotificationSummary Response type: ${responseBody.runtimeType}');

        if (responseBody is Map<String, dynamic>) {
          return NotificationSummaryModel.fromJson(responseBody);
        } else {
          throw Exception(
              'Invalid response format for notification summary: ${responseBody.runtimeType}');
        }
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in getNotificationSummary: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get pending notifications
  static Future<List<NotificationModel>> getPendingNotifications() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getPendingNotificationsUrl()),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        // Debug: Print the response structure
        print(
            'getPendingNotifications Response type: ${responseBody.runtimeType}');

        // Handle different response formats
        List<dynamic> jsonList;
        if (responseBody is List) {
          jsonList = responseBody;
        } else if (responseBody is Map<String, dynamic>) {
          // If the response is wrapped in an object, try to extract the list
          if (responseBody.containsKey('data')) {
            jsonList = responseBody['data'] as List<dynamic>;
          } else {
            // Single object response, wrap in a list
            jsonList = [responseBody];
          }
        } else {
          throw Exception(
              'Unexpected response format: ${responseBody.runtimeType}');
        }

        return jsonList.map((json) {
          try {
            if (json is Map<String, dynamic>) {
              return NotificationModel.fromJson(json);
            } else {
              throw Exception('Invalid JSON item type: ${json.runtimeType}');
            }
          } catch (e) {
            print('Error parsing notification JSON: $e');
            print('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in getPendingNotifications: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get a specific notification by ID
  static Future<NotificationModel> getNotification(int notificationId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getNotificationByIdUrl(notificationId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);
        print('getNotification Response type: ${responseBody.runtimeType}');

        if (responseBody is Map<String, dynamic>) {
          return NotificationModel.fromJson(responseBody);
        } else {
          throw Exception(
              'Invalid response format for single notification: ${responseBody.runtimeType}');
        }
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in getNotification: $e');
      throw Exception('Network error: $e');
    }
  }

  // Create a new notification
  static Future<NotificationModel> createNotification(
      NotificationModel notification) async {
    try {
      final createDto = notification.toCreateDto();
      print('Creating notification with DTO: $createDto');

      final response = await http
          .post(
            Uri.parse(ApiConfig.createNotificationUrl()),
            headers: _headers,
            body: json.encode(createDto),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 201) {
        final dynamic responseBody = json.decode(response.body);
        print('Create notification response type: ${responseBody.runtimeType}');
        print('Create notification response: $responseBody');

        if (responseBody is Map<String, dynamic>) {
          return NotificationModel.fromJson(responseBody);
        } else {
          throw Exception(
              'Invalid response format for created notification: ${responseBody.runtimeType}');
        }
      } else {
        final errorBody = response.body;
        print('Create notification error: ${response.statusCode} - $errorBody');
        throw _handleHttpError(response.statusCode, errorBody);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in createNotification: $e');
      throw Exception('Network error: $e');
    }
  }

  // Mark a notification as read
  static Future<void> markNotificationAsRead(int notificationId) async {
    try {
      print('Marking notification $notificationId as read');

      final response = await http
          .put(
            Uri.parse(ApiConfig.markNotificationAsReadUrl(notificationId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorBody = response.body;
        print('Mark as read error: ${response.statusCode} - $errorBody');
        throw _handleHttpError(response.statusCode, errorBody);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in markNotificationAsRead: $e');
      throw Exception('Network error: $e');
    }
  }

  // Mark a notification as sent
  static Future<void> markNotificationAsSent(int notificationId) async {
    try {
      print('Marking notification $notificationId as sent');

      final response = await http
          .put(
            Uri.parse(ApiConfig.markNotificationAsSentUrl(notificationId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorBody = response.body;
        print('Mark as sent error: ${response.statusCode} - $errorBody');
        throw _handleHttpError(response.statusCode, errorBody);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in markNotificationAsSent: $e');
      throw Exception('Network error: $e');
    }
  }

  // Mark all notifications as read for a customer
  static Future<void> markAllNotificationsAsRead(int customerId) async {
    try {
      print('Marking all notifications as read for customer $customerId');

      final response = await http
          .put(
            Uri.parse(ApiConfig.markAllNotificationsAsReadUrl(customerId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorBody = response.body;
        print('Mark all as read error: ${response.statusCode} - $errorBody');
        throw _handleHttpError(response.statusCode, errorBody);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in markAllNotificationsAsRead: $e');
      throw Exception('Network error: $e');
    }
  }

  // Delete a notification
  static Future<void> deleteNotification(int notificationId) async {
    try {
      print('Deleting notification $notificationId');

      final response = await http
          .delete(
            Uri.parse(ApiConfig.deleteNotificationUrl(notificationId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = response.body;
        print('Delete notification error: ${response.statusCode} - $errorBody');
        throw _handleHttpError(response.statusCode, errorBody);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in deleteNotification: $e');
      throw Exception('Network error: $e');
    }
  }
}
