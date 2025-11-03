import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/service_history_model.dart';

// Debug script specifically for testing POST method to backend
void main() async {
  print('🔧 Testing POST Service History to Backend');
  print('=' * 50);

  const testVehicleId = 1;

  // Test 1: Backend Connection
  print('\n1. 🌐 Testing Backend Connection');
  try {
    final response = await http.get(
      Uri.parse(ApiConfig.getVehicleServiceHistoryUrl(testVehicleId)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    ).timeout(const Duration(seconds: 10));

    print('✅ Backend Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 404) {
      print('❌ Backend not accessible. Response: ${response.body}');
      return;
    }
  } catch (e) {
    print('❌ Connection failed: $e');
    return;
  }

  // Test 2: Create Test Service Data
  print('\n2. 📝 Creating Test Service Data');
  final testService = ServiceHistoryModel(
    vehicleId: testVehicleId,
    serviceType: 'Oil Change',
    description: 'Regular oil change and filter replacement',
    serviceDate: DateTime.now().subtract(const Duration(days: 1)),
    cost: 75.0,
    mileage: 50000,
    isVerified: true,
  );

  print('✅ Test service created:');
  print('   Vehicle ID: ${testService.vehicleId}');
  print('   Service Type: ${testService.serviceType}');
  print('   Description: ${testService.description}');
  print('   Cost: \$${testService.cost}');

  // Test 3: Check JSON Output
  print('\n3. 🔍 Checking JSON Output');
  final createJson = testService.toCreateJson();
  print('✅ Create JSON:');
  print(jsonEncode(createJson));

  // Remove null values to match typical DTO expectations
  final cleanJson = Map<String, dynamic>.from(createJson);
  cleanJson.removeWhere((key, value) => value == null);
  print('✅ Clean JSON (nulls removed):');
  print(jsonEncode(cleanJson));

  // Test 4: POST Request
  print('\n4. 📤 Testing POST Request');
  try {
    final url = ApiConfig.createVehicleServiceHistoryUrl(testVehicleId);
    print('URL: $url');

    final response = await http
        .post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(cleanJson),
        )
        .timeout(const Duration(seconds: 30));

    print('Response Status: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ POST Request SUCCESS!');

      // Try to parse the response
      try {
        final responseData = jsonDecode(response.body);
        print('   Created Service ID: ${responseData['serviceHistoryId']}');
        print('   Created Service: ${responseData['serviceType']}');
      } catch (e) {
        print('   Response parsing failed: $e');
      }
    } else {
      print('❌ POST Request FAILED!');
      print('   Status Code: ${response.statusCode}');
      print('   Error: ${response.body}');

      // Try to parse error response
      try {
        final errorData = jsonDecode(response.body);
        print('   Parsed Error: $errorData');
      } catch (e) {
        print('   Raw Error: ${response.body}');
      }
    }
  } catch (e) {
    print('❌ POST Request Exception: $e');
  }

  // Test 5: Verify Backend Expected Format
  print('\n5. 📋 Backend Expected Format Analysis');
  print('Your .NET controller expects AddServiceHistoryDTO with these fields:');
  print('   ✓ VehicleId (int)');
  print('   ✓ ServiceType (string)');
  print('   ✓ Description (string)');
  print('   ✓ ServiceDate (DateTime)');
  print('   ✓ ServiceCenterId (int?)');
  print('   ✓ ServicedByUserId (int?)');
  print('   ✓ Cost (decimal?)');
  print('   ✓ Mileage (int?)');
  print('   ✓ ExternalServiceCenterName (string?)');
  print('   ✓ ReceiptDocument (string? - base64)');

  print('\n💡 Common POST Issues:');
  print('   1. CORS not configured for POST requests');
  print('   2. Required fields missing in DTO');
  print('   3. Date format mismatch');
  print('   4. Null values not handled properly');
  print('   5. Content-Type header incorrect');

  print('\n' + '=' * 50);
  print('🏁 POST Debug Test Complete');
}
