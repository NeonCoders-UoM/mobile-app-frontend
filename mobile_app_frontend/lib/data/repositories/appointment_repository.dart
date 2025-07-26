import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/appointment_model.dart';
import 'package:mobile_app_frontend/data/models/loyalty_points_model.dart';

class AppointmentRepository {
  final String baseUrl = ApiConfig.baseUrl;

  // Get appointments by customer and vehicle
  Future<List<AppointmentSummary>> getAppointmentsByVehicle(
    int customerId,
    int vehicleId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/Appointment/customer/$customerId/vehicle/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AppointmentSummary.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch appointments');
      }
    } catch (e) {
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  // Get appointment details by ID (returns Map for now since AppointmentDetail doesn't exist)
  Future<Map<String, dynamic>> getAppointmentDetails(
    int customerId,
    int vehicleId,
    int appointmentId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/Appointment/customer/$customerId/vehicle/$vehicleId/details/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch appointment details');
      }
    } catch (e) {
      throw Exception('Failed to fetch appointment details: $e');
    }
  }

  // Get completed appointments for a vehicle (for feedback purposes)
  Future<List<AppointmentSummary>> getCompletedAppointments(
    int customerId,
    int vehicleId,
    String token,
  ) async {
    try {
      final appointments =
          await getAppointmentsByVehicle(customerId, vehicleId, token);
      // For now, return all appointments since status field doesn't exist
      // In a real implementation, you would filter by status
      return appointments;
    } catch (e) {
      throw Exception('Failed to fetch completed appointments: $e');
    }
  }

  // Get the most recent appointment for a vehicle (for feedback purposes)
  Future<Map<String, dynamic>?> getMostRecentAppointment(
    int customerId,
    int vehicleId,
    String token,
  ) async {
    try {
      final appointments =
          await getCompletedAppointments(customerId, vehicleId, token);

      if (appointments.isEmpty) {
        return null;
      }

      // Sort by date and get the most recent
      appointments
          .sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
      final mostRecent = appointments.first;

      return await getAppointmentDetails(
          customerId, vehicleId, mostRecent.appointmentId, token);
    } catch (e) {
      throw Exception('Failed to fetch most recent appointment: $e');
    }
  }

  // Create appointment and return the appointment ID
  Future<int> createAppointmentAndReturnId(
    AppointmentCreate appointment,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Appointment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(appointment.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['appointmentId'] as int;
      } else {
        throw Exception('Failed to create appointment');
      }
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Create appointment (void version)
  Future<void> createAppointment(
    AppointmentCreate appointment,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Appointment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(appointment.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create appointment');
      }
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

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

  // Get total loyalty points for a customer across all appointments
  Future<int> getTotalCustomerLoyaltyPoints(
    int customerId,
    String token,
  ) async {
    try {
      // First get all appointments for the customer
      // Note: This is a simplified approach. In a real implementation,
      // you might want to create a dedicated endpoint for total loyalty points
      final response = await http.get(
        Uri.parse(
            '$baseUrl/Appointment/customer/$customerId/total-loyalty-points'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['totalLoyaltyPoints'] ?? 0;
      } else {
        // If the endpoint doesn't exist, return 0 for now
        return 0;
      }
    } catch (e) {
      // If there's an error, return 0 for now
      print('Error fetching total loyalty points: $e');
      return 0;
    }
  }
}
