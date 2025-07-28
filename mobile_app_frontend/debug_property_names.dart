import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Property Names and Date Formats');
  print('=' * 50);

  await testPropertyNames();
}

Future<void> testPropertyNames() async {
  final baseUrl = 'http://192.168.8.186:5039/api';
  final now = DateTime.now();

  // Test different property names that .NET backend might expect
  final testCases = [
    {
      'description': 'Current format: fuelDate',
      'data': {
        'vehicleId': 1,
        'fuelDate': now.toUtc().toIso8601String(),
        'fuelAmount': 40.0,
        'notes': 'Test current format',
      }
    },
    {
      'description': 'Alternative: date',
      'data': {
        'vehicleId': 1,
        'date': now.toUtc().toIso8601String(),
        'fuelAmount': 40.0,
        'notes': 'Test date property',
      }
    },
    {
      'description': 'Alternative: Date (capitalized)',
      'data': {
        'vehicleId': 1,
        'Date': now.toUtc().toIso8601String(),
        'fuelAmount': 40.0,
        'notes': 'Test Date property',
      }
    },
    {
      'description': 'Alternative: FuelDate (capitalized)',
      'data': {
        'vehicleId': 1,
        'FuelDate': now.toUtc().toIso8601String(),
        'fuelAmount': 40.0,
        'notes': 'Test FuelDate property',
      }
    },
    {
      'description': 'Local time format',
      'data': {
        'vehicleId': 1,
        'fuelDate':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
        'fuelAmount': 40.0,
        'notes': 'Test local time format',
      }
    },
  ];

  for (int i = 0; i < testCases.length; i++) {
    final testCase = testCases[i];
    print('\n${i + 1}️⃣ ${testCase['description']}');
    print('   Data: ${json.encode(testCase['data'])}');

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/FuelEfficiency'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(testCase['data']),
          )
          .timeout(Duration(seconds: 10));

      print('   📡 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('   ✅ SUCCESS!');

        try {
          final responseData = json.decode(response.body);
          print('   📅 Response: $responseData');
        } catch (e) {
          print('   📅 Response (raw): ${response.body}');
        }
      } else {
        print('   ❌ FAILED: ${response.reasonPhrase}');
        print('   📄 Error body: ${response.body}');
      }
    } catch (e) {
      print('   ❌ Request failed: $e');
    }

    await Future.delayed(Duration(milliseconds: 1000));
  }

  // Check what was stored
  print('\n🔍 Checking stored records...');
  await checkResults(baseUrl);
}

Future<void> checkResults(String baseUrl) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/FuelEfficiency/vehicle/1'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> records = json.decode(response.body);

      // Find recent test records
      final testRecords = records
          .where((r) =>
              r['notes'] != null && r['notes'].toString().startsWith('Test '))
          .toList();

      print('📊 Test records found: ${testRecords.length}');

      for (final record in testRecords) {
        final storedDate = record['fuelDate']?.toString() ?? 'NULL';
        final notes = record['notes']?.toString() ?? '';

        print('   ${notes}:');
        print('   └── Stored: $storedDate');

        if (storedDate.startsWith('0001-01-01')) {
          print('   ❌ Date parsing FAILED');
        } else {
          print('   ✅ Date parsing SUCCESS');
        }
      }
    } else {
      print('❌ Could not retrieve records: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
