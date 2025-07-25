import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🩺 Simple Date Format Test');
  print('=' * 30);

  await testSimpleDateFormat();
}

Future<void> testSimpleDateFormat() async {
  final baseUrl = 'http:// 10.10.13.168:5039/api';

  // Test with the most basic date format .NET should accept
  final simpleRecord = {
    'VehicleId': 1,
    'FuelDate': '2025-07-13T15:00:00', // Simple format without timezone
    'FuelAmount': 50.0,
    'PricePerLiter': 160.0,
    'TotalCost': 8000.0,
    'Notes': 'Simple date format test',
  };

  print('📤 Testing simple date format:');
  print('   Data: ${json.encode(simpleRecord)}');

  try {
    final response = await http
        .post(
          Uri.parse('$baseUrl/FuelEfficiency'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(simpleRecord),
        )
        .timeout(Duration(seconds: 10));

    print('\n📡 Response:');
    print('   Status: ${response.statusCode}');
    print('   Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('\n✅ POST succeeded, checking what was stored...');

      // Wait a moment then check
      await Future.delayed(Duration(seconds: 1));

      final getResponse = await http.get(
        Uri.parse('$baseUrl/FuelEfficiency/vehicle/1'),
        headers: {'Accept': 'application/json'},
      );

      if (getResponse.statusCode == 200) {
        final List<dynamic> records = json.decode(getResponse.body);

        // Find our test record
        final testRecord = records
            .where((r) =>
                r['notes'] != null &&
                r['notes'].toString().contains('Simple date format test'))
            .toList();

        if (testRecord.isNotEmpty) {
          final record = testRecord.first;
          print('\n📋 Found our test record:');
          print('   FuelDate stored as: ${record['fuelDate']}');
          print('   All fields: ${json.encode(record)}');

          if (record['fuelDate'].toString().startsWith('0001-01-01')) {
            print('\n❌ Still getting 0001-01-01 - backend DTO issue!');
            print('💡 Possible solutions:');
            print('   1. Check backend DTO property names');
            print('   2. Verify backend DateTime parsing');
            print('   3. Check if backend expects different field name');
          } else {
            print('\n✅ Success! Date was parsed correctly');
          }
        } else {
          print('\n⚠️ Could not find our test record in the response');
        }
      }
    } else {
      print('\n❌ POST failed');
    }
  } catch (e) {
    print('\n❌ Request failed: $e');
  }

  // Also test if we can manually verify the backend is working
  print('\n🔍 Testing if backend is responding at all...');
  try {
    final healthResponse = await http.get(
      Uri.parse('$baseUrl/FuelEfficiency'),
      headers: {'Accept': 'application/json'},
    );

    print('   GET /FuelEfficiency status: ${healthResponse.statusCode}');

    if (healthResponse.statusCode == 200) {
      final data = json.decode(healthResponse.body);
      print('   Total records in DB: ${data.length}');
    }
  } catch (e) {
    print('   Backend connection failed: $e');
  }
}
