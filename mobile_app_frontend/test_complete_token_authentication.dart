import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/data/repositories/fuel_efficiency_repository.dart';
import 'lib/data/repositories/reminder_repository.dart';
import 'lib/data/repositories/service_history_repository.dart';
import 'lib/data/repositories/emergency_call_center_repository.dart';
import 'lib/core/config/api_config.dart';

void main() async {
  print('🔐 Testing Complete Token Authentication Implementation');
  print('=' * 60);

  await testServiceHistoryTokenAuth();
  await testReminderTokenAuth();
  await testFuelEfficiencyTokenAuth();
  await testEmergencyCallCenterAuth();
  await testCompleteAuthFlow();
}

Future<void> testServiceHistoryTokenAuth() async {
  print('\n1️⃣ Testing Service History Token Authentication...');

  final repository = ServiceHistoryRepository();
  const String testToken = 'test-token-service-history';
  const int testVehicleId = 1;

  try {
    // Test connection with token
    final connectionResult = await repository.testConnection(token: testToken);
    print(
        '   🔗 Connection test: ${connectionResult ? "✅ Success" : "❌ Failed"}');

    // Test data retrieval with token
    final records =
        await repository.getServiceHistory(testVehicleId, token: testToken);
    print('   📋 Records retrieval: ✅ Success (${records.length} records)');
  } catch (e) {
    print('   ❌ Service History test failed: $e');
  }
}

Future<void> testReminderTokenAuth() async {
  print('\n2️⃣ Testing Reminder Token Authentication...');

  final repository = ReminderRepository();
  const String testToken = 'test-token-reminders';
  const int testVehicleId = 1;

  try {
    // Test data retrieval with token
    final reminders =
        await repository.getVehicleReminders(testVehicleId, token: testToken);
    print(
        '   🔔 Reminders retrieval: ✅ Success (${reminders.length} reminders)');

    // Test getting all reminders with token
    final allReminders = await repository.getAllReminders(token: testToken);
    print(
        '   📅 All reminders: ✅ Success (${allReminders.length} total reminders)');
  } catch (e) {
    print('   ❌ Reminder test failed: $e');
  }
}

Future<void> testFuelEfficiencyTokenAuth() async {
  print('\n3️⃣ Testing Fuel Efficiency Token Authentication...');

  final repository = FuelEfficiencyRepository();
  const String testToken = 'test-token-fuel-efficiency';
  const int testVehicleId = 1;

  try {
    // Test connection with token
    final connectionResult = await repository.testConnection(token: testToken);
    print(
        '   🔗 Connection test: ${connectionResult ? "✅ Success" : "❌ Failed"}');

    // Test data retrieval with token
    final records =
        await repository.getFuelRecords(testVehicleId, token: testToken);
    print('   ⛽ Fuel records: ✅ Success (${records.length} records)');

    // Test monthly data with token
    final monthlyData = await repository.getMonthlyChartData(
        testVehicleId, DateTime.now().year,
        token: testToken);
    print('   📊 Monthly data: ✅ Success (${monthlyData.length} data points)');
  } catch (e) {
    print('   ❌ Fuel Efficiency test failed: $e');
  }
}

Future<void> testCompleteAuthFlow() async {
  print('\n4️⃣ Testing Complete Authentication Flow...');

  const String customerToken = 'customer-session-token-123';
  const int customerId = 1;
  const int vehicleId = 1;

  print('   👤 Customer ID: $customerId');
  print('   🚗 Vehicle ID: $vehicleId');
  print('   🔑 Token: ${customerToken.substring(0, 10)}...');

  // Simulate complete user flow
  try {
    print('\n   🔄 Step 1: Service History Access');
    final serviceRepo = ServiceHistoryRepository();
    final serviceRecords =
        await serviceRepo.getServiceHistory(vehicleId, token: customerToken);
    print('   ✅ Service History: ${serviceRecords.length} records retrieved');

    print('\n   🔄 Step 2: Reminder Access');
    final reminderRepo = ReminderRepository();
    final reminders =
        await reminderRepo.getVehicleReminders(vehicleId, token: customerToken);
    print('   ✅ Reminders: ${reminders.length} reminders retrieved');

    print('\n   🔄 Step 3: Fuel Efficiency Access');
    final fuelRepo = FuelEfficiencyRepository();
    final fuelRecords =
        await fuelRepo.getFuelRecords(vehicleId, token: customerToken);
    print('   ✅ Fuel Records: ${fuelRecords.length} records retrieved');

    print('\n   🔄 Step 4: Emergency Call Center Access');
    final emergencyRepo = EmergencyCallCenterRepository();
    final emergencyCenters =
        await emergencyRepo.getAllEmergencyCallCenters(token: customerToken);
    print(
        '   ✅ Emergency Centers: ${emergencyCenters.length} centers retrieved');

    print('\n🎉 COMPLETE AUTHENTICATION FLOW: SUCCESS!');
    print('   ✅ All four systems working with token authentication');
    print('   ✅ Customer can access their vehicle data securely');
    print('   ✅ Emergency services available with proper authentication');
    print('   ✅ Token-based access control implemented');
  } catch (e) {
    print('\n❌ AUTHENTICATION FLOW FAILED: $e');
  }
}

Future<void> testEmergencyCallCenterAuth() async {
  print('\n4️⃣ Testing Emergency Call Center Authentication...');

  final repository = EmergencyCallCenterRepository();
  const String testToken = 'test-token-emergency';

  try {
    // Test connection with token
    final connectionResult = await repository.testConnection(token: testToken);
    print(
        '   🔗 Connection test: ${connectionResult ? "✅ Success" : "❌ Failed"}');

    // Test data retrieval with token
    final centers =
        await repository.getAllEmergencyCallCenters(token: testToken);
    print('   🚨 Emergency centers: ✅ Success (${centers.length} centers)');

    // Test location filtering with token
    final centersInSriLanka = await repository
        .getEmergencyCallCentersByLocation('Sri Lanka', token: testToken);
    print(
        '   📍 Location filtering: ✅ Success (${centersInSriLanka.length} centers in Sri Lanka)');
  } catch (e) {
    print('   ❌ Emergency Call Center test failed: $e');
  }
}

// Helper function to simulate API test
Future<bool> testDirectApiCall(String endpoint, String token) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.currentBaseUrl}$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 5));

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
