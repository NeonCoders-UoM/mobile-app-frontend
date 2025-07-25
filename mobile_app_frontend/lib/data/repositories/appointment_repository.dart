// Make sure to add dio: ^5.0.0 (or latest) to your pubspec.yaml dependencies
import 'package:dio/dio.dart';
import '../models/appointment_model.dart';
import 'package:mobile_app_frontend/core/config/api_config.dart';

class AppointmentRepository {
  final Dio dio;
  AppointmentRepository(this.dio);

  Future<List<AppointmentSummary>> getAppointmentsByVehicle(
      int customerId, int vehicleId, String token) async {
    final response = await dio.get(
      '${ApiConfig.currentBaseUrl}/Appointment/customer/$customerId/vehicle/$vehicleId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List)
        .map((json) => AppointmentSummary.fromJson(json))
        .toList();
  }

  Future<void> createAppointment(
      AppointmentCreate appointment, String token) async {
    await dio.post(
      '${ApiConfig.currentBaseUrl}/Appointment',
      data: appointment.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<int> createAppointmentAndReturnId(
      AppointmentCreate appointment, String token) async {
    final response = await dio.post(
      '${ApiConfig.currentBaseUrl}/Appointment',
      data: appointment.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    // Assume backend returns the created appointment as JSON with appointmentId
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      return data['appointmentId'] as int;
    } else {
      throw Exception('Failed to create appointment: \\${response.statusCode}');
    }
  }
}
