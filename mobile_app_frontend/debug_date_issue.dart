import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/data/models/fuel_efficiency_model.dart';
import 'lib/core/config/api_config.dart';

void main() async {
  print('🕐 Debugging Date Issues in Fuel Records');
  print('=' * 50);

  await testDateFormats();
  await testDirectPost();
}

Future<void> testDateFormats() async {
  print('\n1️⃣ Testing Different Date Formats...');

  final now = DateTime.now();
  final testDates = [
    now, // Current local time
    DateTime.utc(now.year, now.month, now.day, now.hour, now.minute), // UTC
    DateTime(now.year, now.month, now.day), // Date only (local)
    DateTime.utc(now.year, now.month, now.day), // Date only (UTC)
  ];

  for (int i = 0; i < testDates.length; i++) {
    final testDate = testDates[i];
    print('\n   Test ${i + 1}: ${_getDateDescription(i)}');
    print('   Raw DateTime: $testDate');
    print('   ISO String: ${testDate.toIso8601String()}');
    print('   Is UTC: ${testDate.isUtc}');

    // Test creating model with this date
    try {
      final model = FuelEfficiencyModel(
        vehicleId: 1,
        fuelDate: testDate,
        fuelAmount: 40.0,
        notes: 'Test date format ${i + 1}',
      );

      final json = model.toCreateJson();
      print('   ✅ Model created successfully');
      print('   JSON fuelDate: ${json['fuelDate']}');
    } catch (e) {
      print('   ❌ Model creation failed: $e');
    }
  }
}

String _getDateDescription(int index) {
  switch (index) {
    case 0:
      return 'Current local time';
    case 1:
      return 'Current UTC time';
    case 2:
      return 'Date only (local)';
    case 3:
      return 'Date only (UTC)';
    default:
      return 'Unknown';
  }
}

Future<void> testDirectPost() async {
  print('\n\n2️⃣ Testing Direct API POST with Different Date Formats...');

  final baseUrl = ApiConfig.currentBaseUrl;
  print('Using API URL: $baseUrl/FuelEfficiency');

  // Test different date formats that might work with .NET backend
  final testRecords = [
    {
      'vehicleId': 1,
      'fuelDate': DateTime.now().toIso8601String(),
      'fuelAmount': 40.0,
      'notes': 'Test 1: ISO with local timezone'
    },
    {
      'vehicleId': 1,
      'fuelDate': DateTime.now().toUtc().toIso8601String(),
      'fuelAmount': 41.0,
      'notes': 'Test 2: ISO with UTC'
    },
    {
      'vehicleId': 1,
      'fuelDate': DateTime.now().toIso8601String().split('T')[0] + 'T00:00:00Z',
      'fuelAmount': 42.0,
      'notes': 'Test 3: Date only with Z suffix'
    },
    {
      'vehicleId': 1,
      'fuelDate': DateTime.now().toIso8601String().replaceAll('Z', '+00:00'),
      'fuelAmount': 43.0,
      'notes': 'Test 4: ISO with explicit timezone offset'
    },
  ];

  for (int i = 0; i < testRecords.length; i++) {
    final record = testRecords[i];
    print('\n   Testing format ${i + 1}: ${record['notes']}');
    print('   Date format: ${record['fuelDate']}');

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/FuelEfficiency'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(record),
          )
          .timeout(Duration(seconds: 10));

      print('   📡 Status: ${response.statusCode}');
      print('   📡 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('   ✅ SUCCESS: This date format works!');
      } else {
        print('   ❌ FAILED: ${response.reasonPhrase}');
        // Try to parse error details
        try {
          final errorData = json.decode(response.body);
          print('   Error details: $errorData');
        } catch (e) {
          print('   Raw error: ${response.body}');
        }
      }
    } catch (e) {
      print('   ❌ Request failed: $e');
    }

    // Small delay between requests
    await Future.delayed(Duration(milliseconds: 500));
  }

  print('\n🔍 Now checking what was actually saved...');
  await _checkSavedRecords();
}

Future<void> _checkSavedRecords() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.currentBaseUrl}/FuelEfficiency/vehicle/1'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> records = json.decode(response.body);

      // Find test records (those with "Test" in notes)
      final testRecords = records
          .where((r) =>
              r['notes'] != null && r['notes'].toString().contains('Test'))
          .toList();

      print('📊 Found ${testRecords.length} test records in database:');

      for (final record in testRecords) {
        print('   - ${record['notes']}: ${record['fuelDate']}');
      }
    } else {
      print('❌ Could not retrieve records: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error checking saved records: $e');
  }
}
