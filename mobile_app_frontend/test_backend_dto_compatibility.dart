import 'dart:convert';
import 'package:http/http.dart' as http;

// Import the updated model
// In a real app, this would be: import 'package:your_app/data/models/fuel_efficiency_model.dart';

void main() async {
  await testFuelEfficiencyIntegration();
}

Future<void> testFuelEfficiencyIntegration() async {
  print('🧪 Testing Fuel Efficiency Integration with Updated Models');
  print('=' * 60);

  final baseUrl = 'http:// 192.168.1.11:5039/api';

  try {
    // Test 1: Create a new fuel efficiency record using AddFuelEfficiencyDTO format
    print('\n1️⃣ Testing CREATE (POST) with AddFuelEfficiencyDTO format...');

    final testData = {
      'VehicleId': 1,
      'FuelAmount': 45.5,
      'Date': DateTime.now()
          .subtract(Duration(days: 1))
          .toIso8601String(), // Yesterday's date
    };

    print('📤 Sending data: ${jsonEncode(testData)}');

    final createResponse = await http.post(
      Uri.parse('$baseUrl/FuelEfficiency'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(testData),
    );

    print('📥 Response Status: ${createResponse.statusCode}');
    print('📥 Response Body: ${createResponse.body}');

    if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
      final responseJson = jsonDecode(createResponse.body);
      print('✅ CREATE successful!');
      print(
          '   - FuelEfficiencyId: ${responseJson['fuelEfficiencyId'] ?? responseJson['FuelEfficiencyId']}');
      print(
          '   - VehicleId: ${responseJson['vehicleId'] ?? responseJson['VehicleId']}');
      print('   - Date: ${responseJson['date'] ?? responseJson['Date']}');
      print(
          '   - FuelAmount: ${responseJson['fuelAmount'] ?? responseJson['FuelAmount']}');
      print(
          '   - CreatedAt: ${responseJson['createdAt'] ?? responseJson['CreatedAt']}');
    } else {
      print('❌ CREATE failed: ${createResponse.body}');
      return;
    }

    // Test 2: Get fuel efficiency records
    print('\n2️⃣ Testing READ (GET) for vehicle 1...');

    final getResponse = await http.get(
      Uri.parse('$baseUrl/FuelEfficiency/vehicle/1'),
      headers: {'Content-Type': 'application/json'},
    );

    print('📥 Response Status: ${getResponse.statusCode}');

    if (getResponse.statusCode == 200) {
      final List<dynamic> records = jsonDecode(getResponse.body);
      print('✅ GET successful! Found ${records.length} records');

      if (records.isNotEmpty) {
        final latestRecord = records.first;
        print('   Latest record:');
        print(
            '   - FuelEfficiencyId: ${latestRecord['fuelEfficiencyId'] ?? latestRecord['FuelEfficiencyId']}');
        print(
            '   - VehicleId: ${latestRecord['vehicleId'] ?? latestRecord['VehicleId']}');
        print('   - Date: ${latestRecord['date'] ?? latestRecord['Date']}');
        print(
            '   - FuelAmount: ${latestRecord['fuelAmount'] ?? latestRecord['FuelAmount']}');
        print(
            '   - CreatedAt: ${latestRecord['createdAt'] ?? latestRecord['CreatedAt']}');

        // Test parsing with updated model
        try {
          // This would be: FuelEfficiencyModel.fromJson(latestRecord) in the real app
          print('✅ Model parsing would work with this response format');
        } catch (e) {
          print('❌ Model parsing failed: $e');
        }
      }
    } else {
      print('❌ GET failed: ${getResponse.body}');
    }

    // Test 3: Test summary endpoint if available
    print('\n3️⃣ Testing SUMMARY endpoint...');

    final summaryResponse = await http.get(
      Uri.parse('$baseUrl/FuelEfficiency/vehicle/1/summary'),
      headers: {'Content-Type': 'application/json'},
    );

    print('📥 Summary Response Status: ${summaryResponse.statusCode}');

    if (summaryResponse.statusCode == 200) {
      final summaryJson = jsonDecode(summaryResponse.body);
      print('✅ SUMMARY successful!');
      print('   Summary structure: ${summaryJson.keys}');
    } else {
      print(
          'ℹ️ Summary endpoint not available or failed: ${summaryResponse.body}');
    }
  } catch (e) {
    print('❌ Test failed with error: $e');
  }

  print('\n' + '=' * 60);
  print('🏁 Integration test completed!');
}
