import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/service_history_model.dart';
import 'package:mobile_app_frontend/data/repositories/service_history_repository.dart';

// Test script for Service History backend integration with VehicleServiceHistoryController
void main() async {
  print('🔧 Testing Service History Backend Integration');
  print('=' * 50);

  final repository = ServiceHistoryRepository();
  const testVehicleId = 1;

  // Test 1: Backend Connection
  print('\n1. 🌐 Testing Backend Connection');
  try {
    final isConnected = await repository.testConnection(
        token: null,
        testVehicleId:
            testVehicleId); // Test without token but with test vehicle ID
    print('✅ Connection Status: ${isConnected ? "Connected" : "Failed"}');

    if (!isConnected) {
      print(
          '❌ Backend is not available. Make sure your .NET API is running on ${ApiConfig.currentBaseUrl}');
      print('   Expected endpoints:');
      print('   - GET ${ApiConfig.getVehicleServiceHistoryUrl(testVehicleId)}');
      print(
          '   - POST ${ApiConfig.createVehicleServiceHistoryUrl(testVehicleId)}');
      print(
          '   - PUT ${ApiConfig.updateVehicleServiceHistoryUrl(testVehicleId, 1)}');
      print(
          '   - DELETE ${ApiConfig.deleteVehicleServiceHistoryUrl(testVehicleId, 1)}');
      return;
    }
  } catch (e) {
    print('❌ Connection test failed: $e');
    return;
  }

  // Test 2: Get Service History for Vehicle
  print('\n2. 📋 Testing Get Service History for Vehicle $testVehicleId');
  try {
    final services = await repository.getServiceHistory(testVehicleId,
        token: null); // Test without token
    print('✅ Retrieved ${services.length} service records');

    if (services.isNotEmpty) {
      print('   Sample records:');
      for (int i = 0; i < services.length && i < 3; i++) {
        final service = services[i];
        print(
            '   - ${service.serviceType} (${service.isVerified ? "Verified" : "Unverified"})');
        print('     Description: ${service.description}');
        print('     Provider: ${service.serviceProvider}');
        print('     Date: ${service.serviceDate.toString().split(' ')[0]}');
        print(
            '     Cost: ${service.cost != null ? '\$${service.cost}' : 'Not specified'}');
        print('     ID: ${service.displayId}');
      }
    } else {
      print('   No service records found for vehicle ID $testVehicleId');
    }
  } catch (e) {
    print('❌ Get service history failed: $e');
  }
  // Test 3: Add Unverified Service (should now go to backend)
  print('\n3. ➕ Testing Add Unverified Service (Backend + Local Fallback)');
  try {
    final testService = ServiceHistoryModel.unverified(
      vehicleId: testVehicleId,
      serviceType: 'Test Oil Change',
      description: 'Regular oil change performed at external garage',
      serviceDate: DateTime.now().subtract(const Duration(days: 7)),
      externalServiceCenterName: 'Test Garage',
      cost: 50.0,
      notes: 'This is a test unverified service record',
    );

    print(
        '📤 Attempting to add unverified service (should try backend first)...');
    final success = await repository.addUnverifiedService(testService,
        token: null); // Test without token
    print('✅ Add unverified service result: ${success ? "Success" : "Failed"}');

    if (success) {
      // Verify it was added by checking the service history
      print('🔍 Verifying service was added...');
      final updatedServices = await repository.getServiceHistory(testVehicleId,
          token: null); // Test without token
      final addedService = updatedServices.firstWhere(
        (s) => s.serviceType == 'Test Oil Change',
        orElse: () => throw Exception('Service not found'),
      );
      print('   ✓ Service found in service history');
      print('   ✓ Service ID: ${addedService.displayId}');
      print('   ✓ Status: ${addedService.status}');
      print('   ✓ Provider: ${addedService.serviceProvider}');
      print('   ✓ Is Verified: ${addedService.isVerified}');

      if (addedService.serviceHistoryId != null &&
          addedService.serviceHistoryId! > 0) {
        print('   🎉 SUCCESS: Service was sent to backend (has positive ID)');
      } else {
        print('   📱 INFO: Service stored locally only (negative/null ID)');
      }
    }
  } catch (e) {
    print('❌ Add unverified service failed: $e');
  }

  // Test 4: Test API Service Creation (if backend supports it)
  print('\n4. 🌐 Testing Add Verified Service (API)');
  try {
    final testVerifiedService = ServiceHistoryModel(
      vehicleId: testVehicleId,
      serviceType: 'API Test Service',
      description: 'Test service created via API',
      serviceDate: DateTime.now().subtract(const Duration(days: 3)),
      serviceCenterName: 'API Test Center',
      cost: 75.0,
      isVerified: true,
      notes: 'This is a test verified service record',
    );

    final success = await repository.addVerifiedService(testVerifiedService,
        token: null); // Test without token
    print('✅ Add verified service via API: ${success ? "Success" : "Failed"}');

    if (!success) {
      print(
          '   ⚠️  This might be expected if the backend VehicleServiceHistory API is not implemented yet');
    }
  } catch (e) {
    print('❌ Add verified service failed: $e');
    print(
        '   ⚠️  This is expected if the backend VehicleServiceHistory API is not implemented yet');
  }

  // Test 5: Get Service Statistics
  print('\n5. 📊 Testing Service Statistics');
  try {
    final stats = await repository.getServiceStatistics(testVehicleId,
        token: null); // Test without token
    print('✅ Service Statistics:');
    print('   Total Services: ${stats['totalServices']}');
    print('   Verified Services: ${stats['verifiedServices']}');
    print('   Unverified Services: ${stats['unverifiedServices']}');
    print('   Total Cost: \$${stats['totalCost'].toStringAsFixed(2)}');
    print(
        '   Last Service: ${stats['lastServiceDate']?.toString().split(' ')[0] ?? 'N/A'}');
  } catch (e) {
    print('❌ Get service statistics failed: $e');
  }

  // Test 6: Direct API endpoint test
  print('\n6. 🔗 Testing Direct API Endpoints');
  await _testDirectApiEndpoints(testVehicleId);

  print('\n' + '=' * 50);
  print('🏁 Backend Integration Test Complete');
  print('\n💡 Next Steps:');
  print('   1. If backend connection failed, ensure your .NET API is running');
  print(
      '   2. Implement VehicleServiceHistoryController endpoints in your .NET backend if not already done');
  print(
      '   3. Test the add unverified service functionality in the Flutter app');
  print(
      '   4. Verify that local unverified services persist between app sessions');
  print(
      '   5. Test CRUD operations (Create, Read, Update, Delete) with the backend');
}

Future<void> _testDirectApiEndpoints(int vehicleId) async {
  final endpoints = [
    {
      'name': 'Get Vehicle Service History',
      'url': ApiConfig.getVehicleServiceHistoryUrl(vehicleId)
    },
    {
      'name': 'Create Service History Endpoint',
      'url': ApiConfig.createVehicleServiceHistoryUrl(vehicleId)
    },
  ];

  for (final endpoint in endpoints) {
    try {
      print('   Testing: ${endpoint['name']}');
      final response = await http.get(
        Uri.parse(endpoint['url']!),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      ).timeout(const Duration(seconds: 5));

      print('     Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          print('     Response: ${data.length} records found');
          if (data.isNotEmpty) {
            print('     Sample Record: ${data.first}');
          }
        } else {
          print('     Response: ${data.toString().substring(0, 100)}...');
        }
      } else if (response.statusCode == 404) {
        print(
            '     Response: Endpoint not found (expected if not implemented)');
      } else {
        print('     Response: ${response.body.substring(0, 100)}...');
      }
    } catch (e) {
      print('     Error: $e');
    }
  }

  // Test specific backend DTO structure
  print('\n   🔍 Testing Backend DTO Structure Compatibility:');
  try {
    final response = await http.get(
      Uri.parse(ApiConfig.getVehicleServiceHistoryUrl(vehicleId)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final serviceData = data.first;
        print('     ✓ Testing DTO field mapping:');

        final expectedFields = [
          'serviceHistoryId',
          'vehicleId',
          'serviceType',
          'description',
          'serviceDate',
          'serviceCenterId',
          'servicedByUserId',
          'serviceCenterName',
          'servicedByUserName',
          'cost',
          'mileage',
          'isVerified',
          'externalServiceCenterName',
          'receiptDocumentPath'
        ];

        for (final field in expectedFields) {
          final hasField = serviceData.containsKey(field);
          print(
              '       ${hasField ? "✓" : "✗"} $field: ${hasField ? "Present" : "Missing"}');
        }

        // Test model creation from backend data
        try {
          final testModel = ServiceHistoryModel.fromJson(serviceData);
          print('     ✅ ServiceHistoryModel.fromJson() works correctly');
          print('       Service Type: ${testModel.serviceType}');
          print('       Description: ${testModel.description}');
          print('       Verified: ${testModel.isVerified}');
        } catch (e) {
          print('     ❌ ServiceHistoryModel.fromJson() failed: $e');
        }
      }
    }
  } catch (e) {
    print('     Error testing DTO structure: $e');
  }
}
