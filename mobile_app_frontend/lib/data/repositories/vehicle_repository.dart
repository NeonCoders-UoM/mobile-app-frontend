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

  Future<void> deleteVehicle(int customerId, int vehicleId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/Customers/$customerId/vehicles/$vehicleId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete vehicle');
    }
  }
}
