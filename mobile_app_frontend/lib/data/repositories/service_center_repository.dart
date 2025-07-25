import 'package:dio/dio.dart';
import '../models/service_center_model.dart';
import '../models/service_model.dart';
import 'package:mobile_app_frontend/core/config/api_config.dart';

class ServiceCenterRepository {
  final Dio dio;
  ServiceCenterRepository(this.dio);

  Future<List<ServiceCenterModel>> getAllServiceCenters(
      {required String token}) async {
    final response = await dio.get(
      '${ApiConfig.currentBaseUrl}/ServiceCenters',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List)
        .map((json) => ServiceCenterModel.fromJson(json))
        .toList();
  }

  Future<List<Service>> getServicesForCenter(
      {required int centerId, required String token}) async {
    final response = await dio.get(
      '${ApiConfig.currentBaseUrl}/ServiceCenters/$centerId/Services',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List)
        .map((json) => Service.fromJson(json))
        .toList();
  }

  // Fetch appointment details (including cost estimation) for a customer, vehicle, and appointment
  Future<Response> getAppointmentDetails({
    required int customerId,
    required int vehicleId,
    required int appointmentId,
    required String token,
  }) async {
    final response = await dio.get(
      '${ApiConfig.currentBaseUrl}/customer/$customerId/vehicle/$vehicleId/details/$appointmentId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response;
  }
}
