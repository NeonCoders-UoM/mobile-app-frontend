import 'package:dio/dio.dart';
import '../models/service_model.dart';
import 'package:mobile_app_frontend/core/config/api_config.dart';

class ServiceRepository {
  final Dio dio;
  ServiceRepository(this.dio);

  Future<List<Service>> getAvailableServices({
    required int serviceCenterId,
    required int weekNumber,
    required String day,
    required String token,
  }) async {
    final response = await dio.get(
      '${ApiConfig.currentBaseUrl}/Service/$serviceCenterId/available',
      queryParameters: {
        'weekNumber': weekNumber,
        'day': day,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List)
        .map((json) => Service.fromJson(json))
        .toList();
  }

  Future<List<Service>> getAllServices({required String token}) async {
    final response = await dio.get(
      '${ApiConfig.currentBaseUrl}/Services',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List)
        .map((json) => Service.fromJson(json))
        .toList();
  }
}
