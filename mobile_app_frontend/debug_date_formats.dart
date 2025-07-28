import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Date Formats for .NET Backend');
  print('=' * 50);

  await testDifferentDateFormats();
}

Future<void> testDifferentDateFormats() async {
  final baseUrl = 'http://192.168.8.186:5039/api';

  // Test different date formats that .NET might accept
  final now = DateTime.now();
  final testFormats = [
    {
      'name': 'Standard ISO with Z',
      'date': now.toUtc().toIso8601String(),
    },
    {
      'name': 'ISO with explicit timezone',
      'date': now.toUtc().toIso8601String().replaceAll('Z', '+00:00'),
    },
    {
      'name': 'ISO without timezone',
      'date': now
          .toIso8601String()
          .replaceAll('Z', '')
          .replaceAll(RegExp(r'\+\d{2}:\d{2}$'), ''),
    },
    {
      'name': '.NET format (yyyy-MM-ddTHH:mm:ss)',
      'date':
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
    },
    {
      'name': '.NET format with milliseconds',
      'date':
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}',
    },
    {
      'name': 'Current local time ISO',
      'date': now.toIso8601String(),
    },
  ];

  for (int i = 0; i < testFormats.length; i++) {
    final format = testFormats[i];
    print('\n${i + 1}️⃣ Testing: ${format['name']}');
    print('   Format: ${format['date']}');

    try {
      final testRecord = {
        'vehicleId': 1,
        'fuelDate': format['date'],
        'fuelAmount': 40.0 + i, // Different amount to distinguish records
        'pricePerLiter': 150.0,
        'totalCost': (40.0 + i) * 150.0,
        'notes': 'Date format test ${i + 1}: ${format['name']}',
      };

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
      print('   📡 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('   ✅ SUCCESS: This format works!');

        // Try to parse the response to see the created record
        try {
          final responseData = json.decode(response.body);
          if (responseData != null && responseData is Map) {
            print(
                '   📅 Backend stored date as: ${responseData['fuelDate'] ?? 'Not returned'}');
          }
        } catch (e) {
          print('   📅 Could not parse response to check stored date');
        }
      } else {
        print('   ❌ FAILED: ${response.reasonPhrase}');

        // Try to get error details
        try {
          final errorData = json.decode(response.body);
          print('   🔍 Error details: $errorData');
        } catch (e) {
          print('   🔍 Raw error: ${response.body}');
        }
      }
    } catch (e) {
      print('   ❌ Request failed: $e');
    }

    // Delay between requests
    await Future.delayed(Duration(milliseconds: 1000));
  }

  // After testing, check what was actually stored
  print('\n🔍 Checking what was stored in database...');
  await checkStoredRecords(baseUrl);
}

Future<void> checkStoredRecords(String baseUrl) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/FuelEfficiency/vehicle/1'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> records = json.decode(response.body);

      // Find test records
      final testRecords = records
          .where((r) =>
              r['notes'] != null &&
              r['notes'].toString().contains('Date format test'))
          .toList();

      print('📊 Found ${testRecords.length} test records:');

      for (final record in testRecords) {
        print('   ${record['notes']}');
        print('   └── Stored date: ${record['fuelDate']}');

        // Check if date is the problematic 0001-01-01
        if (record['fuelDate'].toString().startsWith('0001-01-01')) {
          print('   ❌ BAD: This format resulted in MinValue!');
        } else {
          print('   ✅ GOOD: Date was parsed correctly');
        }
      }
    } else {
      print('❌ Could not retrieve records: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error checking stored records: $e');
  }
}
