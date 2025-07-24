import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Final Property Name Discovery Test');
  print('=' * 42);

  await discoverCorrectPropertyName();
}

Future<void> discoverCorrectPropertyName() async {
  final baseUrl = 'http://192.168.1.11:5039/api';

  // Test all possible property name combinations
  final allPossibleNames = [
    'FuelDate', // Original attempt
    'fuelDate', // camelCase
    'Date', // Simple
    'date', // lowercase
    'FuelDateTime', // Full name
    'fuelDateTime', // camelCase version
    'DatePurchased', // Alternative
    'datePurchased', // camelCase
    'TransactionDate', // Business term
    'transactionDate', // camelCase
    'RecordDate', // Record keeping
    'recordDate', // camelCase
    'EntryDate', // Entry term
    'entryDate', // camelCase
  ];

  for (int i = 0; i < allPossibleNames.length; i++) {
    final propertyName = allPossibleNames[i];
    print('\n${i + 1}️⃣ Testing property: "$propertyName"');

    try {
      final testData = {
        'VehicleId': 1,
        propertyName: '2025-07-13T15:30:00',
        'FuelAmount': 50.0 + i,
        'Notes': 'Test $propertyName property',
      };

      print('   📤 Sending: ${json.encode(testData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/FuelEfficiency'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(testData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final storedDate =
            responseData['fuelDate'] ?? responseData['date'] ?? 'NOT_FOUND';

        print('   ✅ Status: ${response.statusCode}');
        print('   📅 Stored: $storedDate');

        if (!storedDate.toString().startsWith('0001-01-01')) {
          print('   🎯 EUREKA! "$propertyName" works!');
          print('   🔧 Use this in your model: $propertyName');
          break;
        } else {
          print('   ❌ Still 0001-01-01');
        }
      } else {
        print('   ❌ Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('   ❌ Error: $e');
    }

    await Future.delayed(Duration(milliseconds: 300));
  }

  print('\n🤔 If none worked, the issue might be:');
  print('   1. Backend DTO doesn\'t have a date property at all');
  print('   2. Backend requires a different date format');
  print('   3. Backend DTO property is named something unexpected');
  print('   4. Backend has validation that\'s rejecting the date');

  print('\n💡 Suggestion: Check your .NET backend DTO class');
  print('   Look for the property name used for fuel purchase date');
}
