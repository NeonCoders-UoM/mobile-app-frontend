import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Different Property Names for Date');
  print('=' * 50);

  await testDifferentPropertyNames();
}

Future<void> testDifferentPropertyNames() async {
  final baseUrl = 'http://localhost:5039/api';

  // Test different property names the backend might expect
  final propertyTests = [
    {
      'name': 'Date (simple)',
      'data': {
        'VehicleId': 1,
        'Date': '2025-07-13T15:00:00',
        'FuelAmount': 41.0,
        'Notes': 'Test Date property',
      }
    },
    {
      'name': 'ServiceDate (like service history)',
      'data': {
        'VehicleId': 1,
        'ServiceDate': '2025-07-13T15:00:00',
        'FuelAmount': 42.0,
        'Notes': 'Test ServiceDate property',
      }
    },
    {
      'name': 'CreatedDate',
      'data': {
        'VehicleId': 1,
        'CreatedDate': '2025-07-13T15:00:00',
        'FuelAmount': 43.0,
        'Notes': 'Test CreatedDate property',
      }
    },
    {
      'name': 'PurchaseDate',
      'data': {
        'VehicleId': 1,
        'PurchaseDate': '2025-07-13T15:00:00',
        'FuelAmount': 44.0,
        'Notes': 'Test PurchaseDate property',
      }
    },
    {
      'name': 'DateTime',
      'data': {
        'VehicleId': 1,
        'DateTime': '2025-07-13T15:00:00',
        'FuelAmount': 45.0,
        'Notes': 'Test DateTime property',
      }
    },
  ];

  for (int i = 0; i < propertyTests.length; i++) {
    final test = propertyTests[i];
    print('\n${i + 1}️⃣ Testing: ${test['name']}');
    print('   Data: ${json.encode(test['data'])}');

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/FuelEfficiency'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(test['data']),
          )
          .timeout(Duration(seconds: 10));

      print('   📡 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('   ✅ POST Success');

        try {
          final responseData = json.decode(response.body);
          final storedDate =
              responseData['fuelDate'] ?? responseData['date'] ?? 'NOT_FOUND';
          print('   📅 Stored date: $storedDate');

          if (!storedDate.toString().startsWith('0001-01-01')) {
            print('   🎯 SUCCESS! This property name works!');
          } else {
            print('   ❌ Still 0001-01-01');
          }
        } catch (e) {
          print('   📄 Raw response: ${response.body}');
        }
      } else {
        print('   ❌ FAILED: ${response.reasonPhrase}');
        print('   📄 Error: ${response.body}');
      }
    } catch (e) {
      print('   ❌ Request failed: $e');
    }

    await Future.delayed(Duration(milliseconds: 500));
  }

  // Also test what happens if we use NO date field at all
  print('\n6️⃣ Testing with NO date field:');
  try {
    final noDateTest = {
      'VehicleId': 1,
      'FuelAmount': 46.0,
      'Notes': 'Test with no date field',
    };

    print('   Data: ${json.encode(noDateTest)}');

    final response = await http.post(
      Uri.parse('$baseUrl/FuelEfficiency'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(noDateTest),
    );

    print('   📡 Status: ${response.statusCode}');
    print('   📄 Response: ${response.body}');
  } catch (e) {
    print('   ❌ Request failed: $e');
  }
}
