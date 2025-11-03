import 'dart:convert';
import 'package:http/http.dart' as http;

// Simple script to test backend connection
void main() async {
  const String baseUrl = 'http://localhost:5039/api';

  print('Testing backend connection...');

  try {
    // Test 1: Get all reminders
    print('\n1. Testing GET /ServiceReminders');
    final allRemindersResponse = await http.get(
      Uri.parse('$baseUrl/ServiceReminders'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Status: ${allRemindersResponse.statusCode}');
    if (allRemindersResponse.statusCode == 200) {
      final data = json.decode(allRemindersResponse.body);
      print('Response: ${data.length} reminders found');
      if (data.isNotEmpty) {
        print('First reminder: ${data[0]}');
      }
    } else {
      print('Error: ${allRemindersResponse.body}');
    }

    // Test 2: Get vehicle reminders
    print('\n2. Testing GET /ServiceReminders/Vehicle/1');
    final vehicleRemindersResponse = await http.get(
      Uri.parse('$baseUrl/ServiceReminders/Vehicle/1'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Status: ${vehicleRemindersResponse.statusCode}');
    if (vehicleRemindersResponse.statusCode == 200) {
      final data = json.decode(vehicleRemindersResponse.body);
      print('Response: ${data.length} reminders found for vehicle 1');
      for (var reminder in data) {
        print('  - ${reminder['serviceName']}: ${reminder['notes']}');
      }
    } else {
      print('Error: ${vehicleRemindersResponse.body}');
    }

    // Test 3: Create a test reminder
    print('\n3. Testing POST /ServiceReminders');
    final createData = {
      'vehicleId': 1,
      'serviceId': 1,
      'reminderDate':
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'intervalMonths': 6,
      'notifyBeforeDays': 7,
      'notes': 'Test reminder created from Flutter app - Oil change service',
    };

    final createResponse = await http
        .post(
          Uri.parse('$baseUrl/ServiceReminders'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(createData),
        )
        .timeout(const Duration(seconds: 10));

    print('Status: ${createResponse.statusCode}');
    if (createResponse.statusCode == 201) {
      final data = json.decode(createResponse.body);
      print(
          'Created reminder: ${data['serviceName']} with ID ${data['serviceReminderId']}');
      print('Notes: ${data['notes']}');
    } else {
      print('Error: ${createResponse.body}');
    }

    print('\nBackend connection test completed!');
  } catch (e) {
    print('Connection error: $e');
    print('\nMake sure your .NET backend is running on http://localhost:5039');
  }
}
