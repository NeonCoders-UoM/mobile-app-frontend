import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/service_center_model.dart';

class ServiceCenterRepository {
  final String baseUrl = ApiConfig.baseUrl;

  // Get all service centers
  Future<List<ServiceCenterDTO>> getAllServiceCenters() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getServiceCentersUrl()),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ServiceCenterDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch service centers');
      }
    } catch (e) {
      throw Exception('Failed to fetch service centers: $e');
    }
  }

  // Get service centers by status (e.g., "active")
  Future<List<ServiceCenterDTO>> getServiceCentersByStatus(
      String status) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getServiceCentersByStatusUrl(status)),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ServiceCenterDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch service centers by status');
      }
    } catch (e) {
      throw Exception('Failed to fetch service centers by status: $e');
    }
  }

  // Get service center by ID
  Future<ServiceCenterDTO> getServiceCenterById(int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getServiceCenterByIdUrl(id)),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return ServiceCenterDTO.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Service center not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch service center: $e');
    }
  }

  // Get nearby service centers
  Future<List<ServiceCenterDTO>> getNearbyServiceCenters(
    double latitude,
    double longitude,
    List<int> serviceIds,
  ) async {
    try {
      final queryParams = <String, String>{
        'lat': latitude.toString(),
        'lng': longitude.toString(),
      };

      // Add service IDs as query parameters
      for (int i = 0; i < serviceIds.length; i++) {
        queryParams['serviceIds[$i]'] = serviceIds[i].toString();
      }

      final uri = Uri.parse(ApiConfig.getServiceCentersNearbyUrl(
          lat: latitude, lng: longitude, serviceIds: serviceIds));
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ServiceCenterDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch nearby service centers');
      }
    } catch (e) {
      throw Exception('Failed to fetch nearby service centers: $e');
    }
  }

  // Create service center (admin only)
  Future<ServiceCenterDTO> createServiceCenter(
      CreateServiceCenterDTO serviceCenter) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getServiceCentersUrl()),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(serviceCenter.toJson()),
      );

      if (response.statusCode == 201) {
        return ServiceCenterDTO.fromJson(jsonDecode(response.body));
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to create service center');
      }
    } catch (e) {
      throw Exception('Failed to create service center: $e');
    }
  }

  // Update service center (admin only)
  Future<void> updateServiceCenter(
      int id, UpdateServiceCenterDTO serviceCenter) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getServiceCenterByIdUrl(id)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(serviceCenter.toJson()),
      );

      if (response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to update service center');
      }
    } catch (e) {
      throw Exception('Failed to update service center: $e');
    }
  }

  // Update service center status (admin only)
  Future<void> updateServiceCenterStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.getServiceCenterByIdUrl(id)}/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(status),
      );

      if (response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to update service center status');
      }
    } catch (e) {
      throw Exception('Failed to update service center status: $e');
    }
  }

  // Delete service center (admin only)
  Future<void> deleteServiceCenter(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getServiceCenterByIdUrl(id)),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete service center');
      }
    } catch (e) {
      throw Exception('Failed to delete service center: $e');
    }
  }
}
