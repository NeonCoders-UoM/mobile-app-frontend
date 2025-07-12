import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/reminder_model.dart';

class ReminderApiService {
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

  // Get all service reminders
  static Future<List<ServiceReminderModel>> getAllReminders() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getAllRemindersUrl()),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        // Debug: Print the response structure
        print('getAllReminders Response type: ${responseBody.runtimeType}');

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
              return ServiceReminderModel.fromJson(json);
            } else {
              throw Exception('Invalid JSON item type: ${json.runtimeType}');
            }
          } catch (e) {
            print('Error parsing reminder JSON: $e');
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
      print('Network error in getAllReminders: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get reminders for a specific vehicle
  static Future<List<ServiceReminderModel>> getVehicleReminders(
      int vehicleId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getVehicleRemindersUrl(vehicleId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        // Debug: Print the response structure
        print('API Response type: ${responseBody.runtimeType}');
        print('API Response: $responseBody');

        // Handle different response formats
        List<dynamic> jsonList;
        if (responseBody is List) {
          jsonList = responseBody;
        } else if (responseBody is Map<String, dynamic>) {
          // If the response is wrapped in an object, try to extract the list
          if (responseBody.containsKey('data')) {
            jsonList = responseBody['data'] as List<dynamic>;
          } else if (responseBody.containsKey('reminders')) {
            jsonList = responseBody['reminders'] as List<dynamic>;
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
              return ServiceReminderModel.fromJson(json);
            } else {
              throw Exception('Invalid JSON item type: ${json.runtimeType}');
            }
          } catch (e) {
            print('Error parsing reminder JSON: $e');
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
      print('Network error in getVehicleReminders: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get upcoming reminders
  static Future<List<ServiceReminderModel>> getUpcomingReminders(
      {int? days}) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getUpcomingRemindersUrl(days: days)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        // Debug: Print the response structure
        print(
            'getUpcomingReminders Response type: ${responseBody.runtimeType}');

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
              return ServiceReminderModel.fromJson(json);
            } else {
              throw Exception('Invalid JSON item type: ${json.runtimeType}');
            }
          } catch (e) {
            print('Error parsing reminder JSON: $e');
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
      print('Network error in getUpcomingReminders: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get a specific reminder by ID
  static Future<ServiceReminderModel> getReminder(int reminderId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getReminderByIdUrl(reminderId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);
        print('getReminder Response type: ${responseBody.runtimeType}');

        if (responseBody is Map<String, dynamic>) {
          return ServiceReminderModel.fromJson(responseBody);
        } else {
          throw Exception(
              'Invalid response format for single reminder: ${responseBody.runtimeType}');
        }
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in getReminder: $e');
      throw Exception('Network error: $e');
    }
  }

  // Create a new reminder
  static Future<ServiceReminderModel> createReminder(
      ServiceReminderModel reminder) async {
    try {
      final createDto = reminder.toCreateDto();
      print('Creating reminder with DTO: $createDto');

      final response = await http
          .post(
            Uri.parse(ApiConfig.createReminderUrl()),
            headers: _headers,
            body: json.encode(createDto),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 201) {
        final dynamic responseBody = json.decode(response.body);
        print('Create reminder response type: ${responseBody.runtimeType}');
        print('Create reminder response: $responseBody');

        if (responseBody is Map<String, dynamic>) {
          return ServiceReminderModel.fromJson(responseBody);
        } else {
          throw Exception(
              'Invalid response format for created reminder: ${responseBody.runtimeType}');
        }
      } else {
        final errorBody = response.body;
        print('Create reminder error: ${response.statusCode} - $errorBody');
        throw _handleHttpError(response.statusCode, errorBody);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in createReminder: $e');
      throw Exception('Network error: $e');
    }
  }

  // Update an existing reminder
  static Future<void> updateReminder(
      int reminderId, ServiceReminderModel reminder) async {
    try {
      final updateDto = reminder.toUpdateDto();
      print('Updating reminder $reminderId with DTO: $updateDto');

      final response = await http
          .put(
            Uri.parse(ApiConfig.updateReminderUrl(reminderId)),
            headers: _headers,
            body: json.encode(updateDto),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorBody = response.body;
        print('Update reminder error: ${response.statusCode} - $errorBody');
        throw _handleHttpError(response.statusCode, errorBody);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in updateReminder: $e');
      throw Exception('Network error: $e');
    }
  }

  // Delete a reminder
  static Future<void> deleteReminder(int reminderId) async {
    try {
      print('Deleting reminder $reminderId');

      final response = await http
          .delete(
            Uri.parse(ApiConfig.deleteReminderUrl(reminderId)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = response.body;
        print('Delete reminder error: ${response.statusCode} - $errorBody');
        throw _handleHttpError(response.statusCode, errorBody);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('Network error in deleteReminder: $e');
      throw Exception('Network error: $e');
    }
  }
}
