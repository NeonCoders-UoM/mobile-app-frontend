import 'package:http/http.dart' as http;
import 'dart:convert';

// Test script to verify loyalty points integration
void main() async {
  print('🧪 Testing Loyalty Points Integration');
  print('=====================================');

  // Test configuration
  const String baseUrl = 'http://localhost:5039';
  const String testToken =
      'your-test-token-here'; // Replace with actual test token
  const int testCustomerId = 1;
  const int testVehicleId = 1;
  const int testAppointmentId = 1;

  try {
    // Test 1: Get loyalty points for a specific appointment
    print('\n📋 Test 1: Get appointment loyalty points');
    print('Endpoint: GET /api/Appointment/{appointmentId}/loyalty-points');

    final appointmentResponse = await http.get(
      Uri.parse('$baseUrl/api/Appointment/$testAppointmentId/loyalty-points'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $testToken',
      },
    );

    print('Status Code: ${appointmentResponse.statusCode}');
    if (appointmentResponse.statusCode == 200) {
      final data = jsonDecode(appointmentResponse.body);
      print('✅ Success! Response:');
      print('   Appointment ID: ${data['appointmentId']}');
      print('   Customer ID: ${data['customerId']}');
      print('   Vehicle ID: ${data['vehicleId']}');
      print('   Station ID: ${data['stationId']}');
      print('   Loyalty Points: ${data['loyaltyPoints']}');
      print('   Services: ${data['services']?.length ?? 0} services');

      if (data['services'] != null) {
        for (int i = 0; i < data['services'].length; i++) {
          final service = data['services'][i];
          print(
              '     Service ${i + 1}: ID ${service['serviceId']} - ${service['loyaltyPoints']} points');
        }
      }
    } else {
      print('❌ Failed! Response: ${appointmentResponse.body}');
    }

    // Test 2: Get appointments for a customer vehicle
    print('\n📋 Test 2: Get customer vehicle appointments');
    print(
        'Endpoint: GET /api/Appointment/customer/{customerId}/vehicle/{vehicleId}');

    final appointmentsResponse = await http.get(
      Uri.parse(
          '$baseUrl/api/Appointment/customer/$testCustomerId/vehicle/$testVehicleId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $testToken',
      },
    );

    print('Status Code: ${appointmentsResponse.statusCode}');
    if (appointmentsResponse.statusCode == 200) {
      final appointments =
          jsonDecode(appointmentsResponse.body) as List<dynamic>;
      print('✅ Success! Found ${appointments.length} appointments');

      for (int i = 0; i < appointments.length; i++) {
        final appointment = appointments[i];
        print(
            '   Appointment ${i + 1}: ID ${appointment['appointmentId']} - ${appointment['stationName']}');
      }
    } else {
      print('❌ Failed! Response: ${appointmentsResponse.body}');
    }

    // Test 3: Calculate total loyalty points (simulate Flutter app logic)
    print('\n📋 Test 3: Calculate total loyalty points');
    print('This simulates the Flutter app logic for calculating total points');

    if (appointmentsResponse.statusCode == 200) {
      final appointments =
          jsonDecode(appointmentsResponse.body) as List<dynamic>;
      int totalLoyaltyPoints = 0;

      for (final appointment in appointments) {
        final appointmentId = appointment['appointmentId'];
        try {
          final loyaltyResponse = await http.get(
            Uri.parse('$baseUrl/api/Appointment/$appointmentId/loyalty-points'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $testToken',
            },
          );

          if (loyaltyResponse.statusCode == 200) {
            final loyaltyData = jsonDecode(loyaltyResponse.body);
            final points = (loyaltyData['loyaltyPoints'] ?? 0) as int;
            totalLoyaltyPoints += points;
            print('   Appointment $appointmentId: $points points');
          }
        } catch (e) {
          print('   Appointment $appointmentId: Error - $e');
        }
      }

      print('✅ Total Loyalty Points: $totalLoyaltyPoints');
    }

    print('\n🎉 Loyalty Points Integration Test Complete!');
    print('=============================================');
  } catch (e) {
    print('❌ Test failed with error: $e');
  }
}

// Helper function to test with different customer/vehicle combinations
Future<void> testWithDifferentIds() async {
  print('\n🔧 Testing with different customer/vehicle combinations');

  const String baseUrl = 'http://localhost:5039';
  const String testToken = 'your-test-token-here';

  // Test different combinations
  final testCases = [
    {'customerId': 1, 'vehicleId': 1},
    {'customerId': 1, 'vehicleId': 2},
    {'customerId': 2, 'vehicleId': 1},
  ];

  for (final testCase in testCases) {
    final customerId = testCase['customerId']!;
    final vehicleId = testCase['vehicleId']!;

    print('\nTesting Customer $customerId, Vehicle $vehicleId');

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/Appointment/customer/$customerId/vehicle/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $testToken',
        },
      );

      if (response.statusCode == 200) {
        final appointments = jsonDecode(response.body) as List<dynamic>;
        print('   Found ${appointments.length} appointments');
      } else {
        print('   No appointments found or error occurred');
      }
    } catch (e) {
      print('   Error: $e');
    }
  }
}
