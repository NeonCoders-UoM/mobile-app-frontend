import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/reminder_model.dart';

class ReminderApiService {
  // Headers for API requests with optional token
  static Map<String, String> _getHeaders({String? token}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
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
  static Future<List<ServiceReminderModel>> getAllReminders(
      {String? token}) async {
    try {
      print(
          '🔍 Fetching all reminders from: ${ApiConfig.getAllRemindersUrl()}');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getAllRemindersUrl()),
            headers: _getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📡 Response status: ${response.statusCode}');

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

        final reminders = jsonList.map((json) {
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

        print('✅ Retrieved ${reminders.length} reminders from backend');
        return reminders;
      } else if (response.statusCode == 404) {
        print('📭 No reminders found (404 - OK)');
        return [];
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('❌ Network error in getAllReminders: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get reminders for a specific vehicle
  static Future<List<ServiceReminderModel>> getVehicleReminders(int vehicleId,
      {String? token}) async {
    try {
      print(
          '🔍 Fetching vehicle reminders from: ${ApiConfig.getVehicleRemindersUrl(vehicleId)}');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getVehicleRemindersUrl(vehicleId)),
            headers: _getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📡 Response status: ${response.statusCode}');

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
          } else {
            // Single object response, wrap in a list
            jsonList = [responseBody];
          }
        } else {
          throw Exception(
              'Unexpected response format: ${responseBody.runtimeType}');
        }

        final reminders = jsonList.map((json) {
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

        print('✅ Retrieved ${reminders.length} vehicle reminders from backend');
        return reminders;
      } else if (response.statusCode == 404) {
        print('📭 No vehicle reminders found (404 - OK)');
        return [];
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('❌ Network error in getVehicleReminders: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get upcoming reminders
  static Future<List<ServiceReminderModel>> getUpcomingReminders(
      {int? days, String? token}) async {
    try {
      print(
          '🔍 Fetching upcoming reminders from: ${ApiConfig.getUpcomingRemindersUrl(days: days)}');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getUpcomingRemindersUrl(days: days)),
            headers: _getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📡 Response status: ${response.statusCode}');

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

        final reminders = jsonList.map((json) {
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

        print(
            '✅ Retrieved ${reminders.length} upcoming reminders from backend');
        return reminders;
      } else if (response.statusCode == 404) {
        print('📭 No upcoming reminders found (404 - OK)');
        return [];
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('❌ Network error in getUpcomingReminders: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get a specific reminder by ID
  static Future<ServiceReminderModel> getReminder(int reminderId,
      {String? token}) async {
    try {
      print(
          '🔍 Fetching reminder from: ${ApiConfig.getReminderByIdUrl(reminderId)}');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getReminderByIdUrl(reminderId)),
            headers: _getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);
        print('getReminder Response type: ${responseBody.runtimeType}');

        if (responseBody is Map<String, dynamic>) {
          final reminder = ServiceReminderModel.fromJson(responseBody);
          print('✅ Retrieved reminder from backend');
          return reminder;
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
      print('❌ Network error in getReminder: $e');
      throw Exception('Network error: $e');
    }
  }

  // Create a new reminder
  static Future<ServiceReminderModel> createReminder(
      ServiceReminderModel reminder,
      {String? token}) async {
    try {
      final createDto = reminder.toCreateDto();
      print('🔧 Creating reminder with DTO: $createDto');
      print('🔍 Creating reminder at: ${ApiConfig.createReminderUrl()}');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .post(
            Uri.parse(ApiConfig.createReminderUrl()),
            headers: _getHeaders(token: token),
            body: json.encode(createDto),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final dynamic responseBody = json.decode(response.body);
        print('Create reminder response type: ${responseBody.runtimeType}');
        print('Create reminder response: $responseBody');

        if (responseBody is Map<String, dynamic>) {
          final createdReminder = ServiceReminderModel.fromJson(responseBody);
          print('✅ Reminder created successfully');
          return createdReminder;
        } else {
          throw Exception(
              'Invalid response format for created reminder: ${responseBody.runtimeType}');
        }
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('❌ Network error in createReminder: $e');
      throw Exception('Network error: $e');
    }
  }

  // Update an existing reminder
  static Future<void> updateReminder(
      int reminderId, ServiceReminderModel reminder,
      {String? token}) async {
    try {
      final updateDto = reminder.toUpdateDto();
      print('🔧 Updating reminder $reminderId with DTO: $updateDto');
      print(
          '🔍 Updating reminder at: ${ApiConfig.updateReminderUrl(reminderId)}');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .put(
            Uri.parse(ApiConfig.updateReminderUrl(reminderId)),
            headers: _getHeaders(token: token),
            body: json.encode(updateDto),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorBody = response.body;
        print('❌ Update reminder error: ${response.statusCode} - $errorBody');
        throw _handleHttpError(response.statusCode, errorBody);
      } else {
        print('✅ Reminder updated successfully');
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('❌ Network error in updateReminder: $e');
      throw Exception('Network error: $e');
    }
  }

  // Delete a reminder
  static Future<void> deleteReminder(int reminderId, {String? token}) async {
    try {
      print('🔧 Deleting reminder $reminderId');
      print(
          '🔍 Deleting reminder at: ${ApiConfig.deleteReminderUrl(reminderId)}');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .delete(
            Uri.parse(ApiConfig.deleteReminderUrl(reminderId)),
            headers: _getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = response.body;
        print('❌ Delete reminder error: ${response.statusCode} - $errorBody');
        throw _handleHttpError(response.statusCode, errorBody);
      } else {
        print('✅ Reminder deleted successfully');
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'CORS Error: Please configure CORS in your .NET backend to allow requests from ${Uri.base.origin}');
      }
      print('❌ Network error in deleteReminder: $e');
      throw Exception('Network error: $e');
    }
  }

  // Test backend connection for reminders
  static Future<bool> testConnection({String? token}) async {
    try {
      print(
          '🔍 Testing reminder backend connection to: ${ApiConfig.getAllRemindersUrl()}');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getAllRemindersUrl()),
            headers: _getHeaders(token: token),
          )
          .timeout(const Duration(seconds: 5));

      print('📡 Reminder connection test response: ${response.statusCode}');

      // Accept 200 (success), 404 (no data), or 401 (unauthorized but server is up)
      // These all indicate the server is reachable and responding
      final isConnected = response.statusCode == 200 ||
          response.statusCode == 404 ||
          response.statusCode == 401;

      print(
          '🌐 Reminder backend connection: ${isConnected ? "✅ Success" : "❌ Failed"}');
      return isConnected;
    } catch (e) {
      print('❌ Reminder backend connection test failed: $e');
      return false;
    }
  }
}
