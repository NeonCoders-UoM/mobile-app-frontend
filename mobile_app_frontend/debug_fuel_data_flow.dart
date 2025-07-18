import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/core/config/api_config.dart';
import 'lib/data/models/fuel_efficiency_model.dart';
import 'lib/data/repositories/fuel_efficiency_repository.dart';

void main() async {
  print('🔍 Debugging Fuel Efficiency Data Flow Issue');
  print('=' * 60);

  // Test 1: Check backend connection and port
  await testBackendConnection();

  // Test 2: Test adding a record
  await testAddRecord();

  // Test 3: Test retrieving records immediately after adding
  await testRetrieveRecords();

  // Test 4: Test API endpoints directly
  await testDirectApiCalls();
}

Future<void> testBackendConnection() async {
  print('\n1️⃣ Testing Backend Connection...');
  print('Current API config: ${ApiConfig.currentBaseUrl}');

  try {
    // Test multiple possible ports
    final ports = [5039, 5000, 5001, 7000, 7001];

    for (final port in ports) {
      try {
        final testUrl = 'http://localhost:$port/api/FuelEfficiency';
        print('🔌 Testing port $port...');

        final response = await http.get(
          Uri.parse(testUrl),
          headers: {'Content-Type': 'application/json'},
        ).timeout(Duration(seconds: 3));

        print('   ✅ Port $port responded with status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(
              '   📊 Data count: ${data is List ? data.length : 'Unknown format'}');

          if (port != 5039) {
            print(
                '   ⚠️ WARNING: Backend is running on port $port, but API config uses 5039!');
          }
        }
      } catch (e) {
        print(
            '   ❌ Port $port not accessible: ${e.toString().split(':').first}');
      }
    }
  } catch (e) {
    print('❌ Connection test failed: $e');
  }
}

Future<void> testAddRecord() async {
  print('\n2️⃣ Testing Add Record...');

  try {
    final repository = FuelEfficiencyRepository();

    // Create a test record
    final testRecord = FuelEfficiencyModel(
      vehicleId: ApiConfig.defaultVehicleId,
      fuelDate: DateTime.now(),
      fuelAmount: 45.5,
      pricePerLiter: 1.65,
      totalCost: 75.08,
      odometer: 15500,
      location: 'Test Station Debug',
      fuelType: 'Petrol',
      notes: 'Debug test record - ${DateTime.now().millisecondsSinceEpoch}',
    );

    print('📝 Attempting to add record...');
    print('   Data to send: ${json.encode(testRecord.toCreateJson())}');

    final success = await repository.addFuelRecord(testRecord);

    if (success) {
      print('✅ Record added successfully to backend');
    } else {
      print('❌ Failed to add record to backend');
    }
  } catch (e) {
    print('❌ Add record test failed: $e');
  }
}

Future<void> testRetrieveRecords() async {
  print('\n3️⃣ Testing Retrieve Records...');

  try {
    final repository = FuelEfficiencyRepository();

    print('🔍 Fetching records immediately after add...');
    final records = await repository.getFuelRecords(ApiConfig.defaultVehicleId);

    print('📊 Retrieved ${records.length} records');

    if (records.isNotEmpty) {
      print('   Latest record:');
      final latest = records.last;
      print('   - ID: ${latest.fuelEfficiencyId}');
      print('   - Date: ${latest.fuelDate}');
      print('   - Amount: ${latest.fuelAmount}L');
      print('   - Notes: ${latest.notes}');
      print('   - Created: ${latest.createdAt}');
    } else {
      print('   ⚠️ No records found - this indicates the issue!');
    }
  } catch (e) {
    print('❌ Retrieve records test failed: $e');
  }
}

Future<void> testDirectApiCalls() async {
  print('\n4️⃣ Testing Direct API Calls...');

  try {
    // Test GET call directly
    print('🔍 Direct GET call...');
    final getUrl =
        '${ApiConfig.currentBaseUrl}/FuelEfficiency/vehicle/${ApiConfig.defaultVehicleId}';
    print('   URL: $getUrl');

    final getResponse = await http.get(
      Uri.parse(getUrl),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 10));

    print('   Status: ${getResponse.statusCode}');
    print('   Body: ${getResponse.body}');

    if (getResponse.statusCode == 200) {
      final data = json.decode(getResponse.body);
      print('   ✅ Successfully retrieved ${data.length} records directly');

      // Show sample data structure
      if (data.isNotEmpty) {
        print('   📝 Sample record structure:');
        final sample = data.first;
        print('   ${json.encode(sample)}');
      }
    } else {
      print('   ❌ Direct GET failed');
    }
  } catch (e) {
    print('❌ Direct API test failed: $e');
  }
}
