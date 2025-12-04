import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/models/vehicle.dart';

class VehicleRepository {
  final String baseUrl;
  VehicleRepository(this.baseUrl);

  Future<List<Vehicle>> fetchVehicles(int customerId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Customers/$customerId/vehicles'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((v) => Vehicle.fromJson(v)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  Future<Vehicle> addVehicle(int customerId, Map<String, dynamic> vehicleData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Customers/$customerId/vehicles'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(vehicleData),
    );
    if (response.statusCode == 201) {
      return Vehicle.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add vehicle');
    }
  }

  Future<void> updateVehicle(int customerId, int vehicleId, Map<String, dynamic> vehicleData, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/Customers/$customerId/vehicles/$vehicleId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(vehicleData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update vehicle');
    }
  }

  Future<void> deleteVehicle(int customerId, int vehicleId, String token, String password) async {
    try {
      // First get the customer's email
      final customerUrl = Uri.parse('$baseUrl/api/Customers/$customerId');
      final customerResponse = await http.get(
        customerUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (customerResponse.statusCode != 200) {
        print('❌ Could not retrieve customer details: ${customerResponse.statusCode}');
        throw Exception('Could not retrieve customer information. Please try again.');
      }

      final customerData = jsonDecode(customerResponse.body);
      final email = customerData['email'];

      if (email == null) {
        print('❌ Customer email not found in response');
        throw Exception('Could not retrieve customer email. Please try again.');
      }

      print('🔑 VERIFY Password for CustomerID: $customerId with email: $email');

      // Use direct HTTP call to login endpoint for password verification
      final loginUrl = Uri.parse('$baseUrl/api/Auth/login-customer');
      
      print('🔐 Making login request to: $loginUrl');
      print('📧 Email: $email');
      print('🔒 Password: ${password.length} characters');

      final loginResponse = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('🔍 Login Response Code: ${loginResponse.statusCode}');
      print('🔍 Login Response Body: ${loginResponse.body}');

      if (loginResponse.statusCode != 200) {
        print('❌ Password verification failed: ${loginResponse.statusCode}');
        throw Exception('Invalid password. Please check your password and try again.');
      }

      print('✅ Password verified successfully via repository');

      // If password is valid, proceed with vehicle deletion
      final response = await http.delete(
        Uri.parse('$baseUrl/api/Customers/$customerId/vehicles/$vehicleId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Vehicle deleted successfully via repository');
        return;
      } else if (response.statusCode == 404) {
        print('❌ Vehicle not found');
        throw Exception('Vehicle not found.');
      } else {
        print('❌ Failed to delete vehicle: ${response.statusCode} ${response.body}');
        throw Exception('Failed to delete vehicle. Please try again.');
      }
    } catch (e) {
      print('❌ Error deleting vehicle via repository: $e');
      rethrow;
    }
  }
}
