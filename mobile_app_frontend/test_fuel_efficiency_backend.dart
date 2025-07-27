import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/fuel_efficiency_model.dart';
import 'package:mobile_app_frontend/data/repositories/fuel_efficiency_repository.dart';

// Test script specifically for fuel efficiency backend integration
void main() async {
  print('⛽ Testing Fuel Efficiency Backend Integration');
  print('=' * 60);

  const testVehicleId = 1;
  final repository = FuelEfficiencyRepository();

  // Test 1: Backend Connection
  print('\n1. 🌐 Testing Backend Connection');
  try {
    final isConnected = await repository.testConnection();
    print('✅ Backend Connection: ${isConnected ? 'SUCCESS' : 'FAILED'}');

    if (!isConnected) {
      print(
          '❌ Backend not accessible. Please ensure your .NET API is running on ${ApiConfig.baseUrl}');
      print(
          '   Make sure FuelEfficiencyController is implemented and CORS is configured.');
      return;
    }
  } catch (e) {
    print('❌ Connection test failed: $e');
    return;
  }

  // Test 2: Get Fuel Records
  print('\n2. 📋 Testing Get Fuel Records');
  try {
    final records = await repository.getFuelRecords(testVehicleId);
    print('✅ Retrieved ${records.length} fuel records');

    if (records.isNotEmpty) {
      final firstRecord = records.first;
      print('   Sample record:');
      print('   - Date:  [33m${firstRecord.fuelDate} [0m');
      print('   - Amount: ${firstRecord.fuelAmount}L');
      print('   - Type: ${firstRecord.fuelType ?? 'N/A'}');
    }
  } catch (e) {
    print('❌ Get fuel records failed: $e');
  }

  // Test 3: Test Create Fuel Record
  print('\n3. 📝 Testing Create Fuel Record');
  try {
    final testRecord = FuelEfficiencyModel(
      vehicleId: testVehicleId,
      date: DateTime.now()
          .subtract(const Duration(days: 1)), // changed from fuelDate to date
      fuelAmount: 45.5,
      odometer: 85000,
      location: 'Test Station',
      fuelType: 'Petrol',
      notes: 'Test fuel record from Flutter app',
    );

    print('Creating test fuel record:');
    print('   Vehicle ID: ${testRecord.vehicleId}');
    print('   Amount: ${testRecord.fuelAmount}L');
    print('   JSON: ${json.encode(testRecord.toCreateJson())}');

    final success = await repository.addFuelRecord(testRecord);
    print('✅ Create fuel record: ${success ? 'SUCCESS' : 'FAILED'}');
  } catch (e) {
    print('❌ Create fuel record failed: $e');
  }

  // Test 4: Test Get Summary
  print('\n4. 📊 Testing Get Fuel Summary');
  try {
    final currentYear = DateTime.now().year;
    final summary =
        await repository.getFuelSummary(testVehicleId, year: currentYear);

    if (summary != null) {
      print('✅ Fuel Summary for $currentYear:');
      print('   Total Fuel: ${summary.totalFuelAmount}L');
      print('   Total Records: ${summary.totalRecords}');
    } else {
      print('ℹ️ No summary data available for year $currentYear');
    }
  } catch (e) {
    print('❌ Get fuel summary failed: $e');
  }

  // Test 5: Test Monthly Chart Data
  print('\n5. 📈 Testing Monthly Chart Data');
  try {
    final currentYear = DateTime.now().year;
    final chartData =
        await repository.getMonthlyChartData(testVehicleId, currentYear);

    print('✅ Retrieved ${chartData.length} months of chart data');
    for (var monthData in chartData.take(3)) {
      // Show first 3 months
      print('   ${monthData.monthName}: ${monthData.totalFuelAmount}L');
    }
  } catch (e) {
    print('❌ Get monthly chart data failed: $e');
  }

  // Test 6: Direct API Endpoints
  print('\n6. 🔗 Testing Direct API Endpoints');
  await _testDirectApiEndpoints(testVehicleId);

  print('\n' + '=' * 60);
  print('🏁 Fuel Efficiency Backend Integration Test Complete');

  print('\n💡 Next Steps:');
  print(
      '   1. If any tests failed, check your .NET FuelEfficiencyController implementation');
  print('   2. Verify CORS configuration allows requests from Flutter web');
  print('   3. Test the Flutter app fuel summary page');
  print('   4. Check network tab in browser for API call details');

  print('\n📋 Expected Backend Endpoints:');
  print('   GET    /api/FuelEfficiency/vehicle/{vehicleId}');
  print(
      '   GET    /api/FuelEfficiency/vehicle/{vehicleId}/summary?year={year}');
  print('   GET    /api/FuelEfficiency/vehicle/{vehicleId}/chart/{year}');
  print('   POST   /api/FuelEfficiency');
  print('   PUT    /api/FuelEfficiency/{id}');
  print('   DELETE /api/FuelEfficiency/{id}');
}

Future<void> _testDirectApiEndpoints(int vehicleId) async {
  final endpoints = [
    {
      'name': 'Get Vehicle Fuel Records',
      'url': ApiConfig.getFuelEfficienciesByVehicleUrl(vehicleId),
      'method': 'GET'
    },
    {
      'name': 'Get Fuel Summary',
      'url': ApiConfig.getFuelEfficiencySummaryUrl(vehicleId),
      'method': 'GET'
    },
    {
      'name': 'Add Fuel Record Endpoint',
      'url': ApiConfig.addFuelEfficiencyUrl(),
      'method': 'POST'
    },
  ];

  for (final endpoint in endpoints) {
    try {
      print('   Testing: ${endpoint['name']}');
      print('   URL: ${endpoint['url']}');

      final response = await http.get(
        Uri.parse(endpoint['url']!),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      ).timeout(const Duration(seconds: 10));

      print('   Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          print('   Response: List with ${data.length} items');
        } else if (data is Map) {
          print('   Response: Object with ${data.keys.length} fields');
        }
      } else if (response.statusCode == 404) {
        print('   Response: No data found (404 - OK for empty data)');
      } else {
        print('   Error: ${response.body}');
      }
    } catch (e) {
      print('   ❌ Failed: $e');
    }
    print('');
  }
}
