import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Final Fix - No Date Field');
  print('=' * 40);

  await testFinalFix();
}

Future<void> testFinalFix() async {
  final baseUrl = 'http://192.168.8.186:5039/api';

  // Test without sending date field - let backend auto-set it
  final testRecord = {
    'VehicleId': 1,
    'FuelAmount': 55.0,
    'PricePerLiter': 165.0,
    'TotalCost': 9075.0,
    'Odometer': 16000,
    'Location': 'Final Test Station',
    'FuelType': 'Petrol',
    'Notes': 'Final fix test - no date field sent',
  };

  print('📤 Testing without date field:');
  print('   Data: ${json.encode(testRecord)}');

  try {
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

    print('\n📡 Response:');
    print('   Status: ${response.statusCode}');
    print('   Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('\n✅ POST succeeded!');

      final responseData = json.decode(response.body);
      final storedDate =
          responseData['fuelDate'] ?? responseData['date'] ?? 'NOT_FOUND';

      print('📅 Backend set date as: $storedDate');

      if (!storedDate.toString().startsWith('0001-01-01')) {
        print('🎯 SUCCESS! Backend auto-set a valid date!');
        print('💡 Solution: Don\'t send date field, let backend handle it');
      } else {
        print('❌ Still getting 0001-01-01');
        print('🤔 Backend DTO might have other issues');
      }

      // Wait and check what was actually stored
      print('\n🔍 Checking stored record...');
      await Future.delayed(Duration(seconds: 1));

      final getResponse = await http.get(
        Uri.parse('$baseUrl/FuelEfficiency/vehicle/1'),
        headers: {'Accept': 'application/json'},
      );

      if (getResponse.statusCode == 200) {
        final List<dynamic> records = json.decode(getResponse.body);

        final testRecords = records
            .where((r) =>
                r['notes'] != null &&
                r['notes'].toString().contains('Final fix test'))
            .toList();

        if (testRecords.isNotEmpty) {
          final record = testRecords.first;
          print('📋 Stored record:');
          print('   ID: ${record['fuelEfficiencyId']}');
          print('   Date: ${record['fuelDate'] ?? record['date']}');
          print('   Amount: ${record['fuelAmount']}');
          print('   Notes: ${record['notes']}');
          print('   Created: ${record['createdAt']}');

          final finalDate = record['fuelDate'] ?? record['date'];
          if (!finalDate.toString().startsWith('0001-01-01')) {
            print('\n🎉 FINAL SUCCESS!');
            print('✅ Date is now correctly set by backend');
            print('🔧 Update your Flutter model to not send date field');
          } else {
            print('\n⚠️ Still seeing 0001-01-01 in stored record');
            print('🆘 This indicates a backend configuration issue');
          }
        }
      }
    } else {
      print('\n❌ POST failed: ${response.reasonPhrase}');
      print('📄 Error details: ${response.body}');
    }
  } catch (e) {
    print('\n❌ Request failed: $e');
  }
}
