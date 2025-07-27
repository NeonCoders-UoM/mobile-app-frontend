import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/loyalty_points_model.dart';
import 'package:mobile_app_frontend/data/models/appointment_model.dart';

class LoyaltyPointsRepository {
  final String baseUrl = ApiConfig.baseUrl;

  // Get loyalty points for a specific appointment
  Future<LoyaltyPointsModel> getAppointmentLoyaltyPoints(
    int appointmentId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Appointment/$appointmentId/loyalty-points'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoyaltyPointsModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch loyalty points');
      }
    } catch (e) {
      throw Exception('Failed to fetch loyalty points: $e');
    }
  }

  // Get total loyalty points for a customer across all vehicles and appointments
  Future<int> getTotalCustomerLoyaltyPoints(
    int customerId,
    String token,
  ) async {
    try {
      int totalLoyaltyPoints = 0;

      // First, get all vehicles for the customer
      final vehiclesResponse = await http.get(
        Uri.parse('$baseUrl/Customers/$customerId/vehicles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (vehiclesResponse.statusCode == 200) {
        final vehicles = jsonDecode(vehiclesResponse.body) as List<dynamic>;

        // For each vehicle, get appointments and calculate loyalty points
        for (final vehicle in vehicles) {
          final vehicleId = vehicle['vehicleId'] ?? vehicle['VehicleId'];
          if (vehicleId != null) {
            final vehicleLoyaltyPoints =
                await _getVehicleLoyaltyPoints(customerId, vehicleId, token);
            totalLoyaltyPoints += vehicleLoyaltyPoints;
          }
        }
      }

      return totalLoyaltyPoints;
    } catch (e) {
      print('Error calculating total loyalty points: $e');
      return 0;
    }
  }

  // Get loyalty points for a specific vehicle
  Future<int> getVehicleLoyaltyPoints(
    int customerId,
    int vehicleId,
    String token,
  ) async {
    return await _getVehicleLoyaltyPoints(customerId, vehicleId, token);
  }

  // Private method to get loyalty points for a vehicle
  Future<int> _getVehicleLoyaltyPoints(
    int customerId,
    int vehicleId,
    String token,
  ) async {
    try {
      int totalLoyaltyPoints = 0;

      // Get all appointments for this vehicle
      final appointmentsResponse = await http.get(
        Uri.parse(
            '$baseUrl/Appointment/customer/$customerId/vehicle/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (appointmentsResponse.statusCode == 200) {
        final appointments =
            jsonDecode(appointmentsResponse.body) as List<dynamic>;

        // For each appointment, get loyalty points
        for (final appointment in appointments) {
          final appointmentId = appointment['appointmentId'];
          if (appointmentId != null) {
            try {
              final loyaltyPoints =
                  await getAppointmentLoyaltyPoints(appointmentId, token);
              totalLoyaltyPoints += loyaltyPoints.loyaltyPoints;
            } catch (e) {
              // If individual appointment fails, continue with others
              print(
                  'Error fetching loyalty points for appointment $appointmentId: $e');
            }
          }
        }
      }

      return totalLoyaltyPoints;
    } catch (e) {
      print('Error calculating vehicle loyalty points: $e');
      return 0;
    }
  }
}
