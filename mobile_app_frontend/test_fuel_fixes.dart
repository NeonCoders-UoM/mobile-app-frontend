import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/data/models/fuel_efficiency_model.dart';

void main() async {
  print('🧪 Testing Fuel Efficiency Integration Fixes');
  print('=' * 50);

  // Test 1: Model parsing with null values
  await testModelParsing();

  // Test 2: Backend connection
  await testBackendConnection();
}

Future<void> testModelParsing() async {
  print('\n1️⃣ Testing model parsing with null values...');

  try {
    // Test case with null values that previously caused errors
    final testData = {
      'fuelEfficiencyId': 1,
      'vehicleId': null, // This was causing the error
      'fuelDate': '2024-01-15T00:00:00',
      'fuelAmount': 45.5,
      'totalCost': 68.25,
      'odometer': 15000,
      'fuelEfficiency': null, // Another potential null
      'notes': null
    };

    final model = FuelEfficiencyModel.fromJson(testData);
    print('✅ FuelEfficiencyModel parsed successfully');
    print('   - vehicleId: ${model.vehicleId}');
    print('   - notes: ${model.notes}');

    // Test summary model
    final summaryData = {
      'vehicleId': null,
      'totalRecords': 12,
      'totalFuelAmount': 540.0,
      'totalCost': 810.0,
      'averageEfficiency': 8.5,
      'bestEfficiency': 9.2,
      'worstEfficiency': 7.8
    };

    final summaryModel = FuelEfficiencySummaryModel.fromJson(summaryData);
    print('✅ FuelEfficiencySummaryModel parsed successfully');
    print('   - vehicleId: ${summaryModel.vehicleId}');

    // Test monthly model
    final monthlyData = {
      'year': 2024,
      'month': 1,
      'monthName': null, // Potential null
      'totalFuelAmount': 90.0,
      'totalCost': 135.0,
      'averageEfficiency': 8.5,
      'recordCount': 3
    };

    final monthlyModel = MonthlyFuelSummaryModel.fromJson(monthlyData);
    print('✅ MonthlyFuelSummaryModel parsed successfully');
    print('   - monthName: ${monthlyModel.monthName}');
    print('   - displayMonth: ${monthlyModel.displayMonth}');
  } catch (e) {
    print('❌ Model parsing failed: $e');
  }
}

Future<void> testBackendConnection() async {
  print('\n2️⃣ Testing backend connection...');

  try {
    // Test basic connection to fuel efficiency endpoint
    final response = await http.get(
      Uri.parse('http://localhost:5000/api/fuelefficiency'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 5));

    print('📡 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Backend connection successful');
      print('   - Records received: ${data is List ? data.length : 'Unknown'}');
    } else {
      print('⚠️ Backend returned status: ${response.statusCode}');
      print('   - Body: ${response.body}');
    }
  } catch (e) {
    print('❌ Backend connection failed: $e');
    print('   - Make sure your backend is running on localhost:5000');
  }
}
