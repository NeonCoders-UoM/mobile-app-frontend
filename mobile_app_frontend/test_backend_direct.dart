import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Direct Backend Test - Date Issue Diagnosis');
  print('=' * 55);

  await testBackendDirectly();
}

Future<void> testBackendDirectly() async {
  final baseUrl = 'http:// 192.168.8.186:5039/api';

  // Test different date formats that might work better with .NET
  final testFormats = [
    {
      'name': 'Standard UTC ISO',
      'date': DateTime.now().toUtc().toIso8601String(),
    },
    {
      'name': 'UTC without microseconds',
      'date': DateTime.now().toUtc().toIso8601String().split('.')[0] + 'Z',
    },
    {
      'name': 'Local time without timezone',
      'date': DateTime.now().toIso8601String().split('.')[0],
    },
    {
      'name': '.NET DateTime format',
      'date':
          DateTime.now().toUtc().toIso8601String().replaceAll('Z', '+00:00'),
    },
    {
      'name': 'Simple date format',
      'date': '2025-07-13T14:30:00',
    },
  ];

  for (int i = 0; i < testFormats.length; i++) {
    final format = testFormats[i];
    print('\n${i + 1}️⃣ Testing: ${format['name']}');
    print('   Date: ${format['date']}');

    try {
      final testRecord = {
        'VehicleId': 1,
        'FuelDate': format['date'],
        'FuelAmount': 40.0 + i,
        'PricePerLiter': 150.0,
        'TotalCost': (40.0 + i) * 150.0,
        'Notes': 'Test ${i + 1}: ${format['name']}',
      };

      print('   📤 Sending: ${json.encode(testRecord)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/FuelEfficiency'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(testRecord),
          )
          .timeout(Duration(seconds: 10));

      print('   📡 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('   ✅ SUCCESS');

        // Parse response to see what was created
        try {
          final responseData = json.decode(response.body);
          print('   📅 Backend response: ${responseData}');
        } catch (e) {
          print('   📅 Response body: ${response.body}');
        }
      } else {
        print('   ❌ FAILED: ${response.reasonPhrase}');
        print('   📄 Error: ${response.body}');
      }
    } catch (e) {
      print('   ❌ Request failed: $e');
    }

    // Small delay
    await Future.delayed(Duration(milliseconds: 1000));
  }

  // Check what was actually stored
  print('\n🔍 Checking stored records...');
  await checkStoredData(baseUrl);
}

Future<void> checkStoredData(String baseUrl) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/FuelEfficiency/vehicle/1'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> records = json.decode(response.body);

      // Find recent test records
      final now = DateTime.now();
      final recentRecords = records.where((r) {
        if (r['notes'] != null && r['notes'].toString().startsWith('Test ')) {
          return true;
        }
        // Also check by creation time if available
        if (r['createdAt'] != null) {
          try {
            final createdAt = DateTime.parse(r['createdAt']);
            return now.difference(createdAt).inMinutes < 10;
          } catch (e) {
            return false;
          }
        }
        return false;
      }).toList();

      print('📊 Found ${recentRecords.length} recent test records:');

      for (final record in recentRecords) {
        final storedDate = record['fuelDate']?.toString() ?? 'NULL';
        final notes = record['notes']?.toString() ?? '';

        print('\n   📝 ${notes}');
        print('   📅 Stored FuelDate: $storedDate');

        // Check specific fields
        print('   🔍 All fields:');
        record.forEach((key, value) {
          print('      $key: $value');
        });

        if (storedDate.startsWith('0001-01-01')) {
          print('   ❌ BAD: Date parsing failed!');
        } else {
          print('   ✅ GOOD: Date parsed correctly');
        }
        print('   ${'-' * 40}');
      }
    } else {
      print('❌ Could not retrieve records: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Error checking records: $e');
  }
}
