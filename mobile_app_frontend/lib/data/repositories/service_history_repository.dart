import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/service_history_model.dart';
import 'dart:typed_data'; // Added for Uint8List

class ServiceHistoryRepository {
  // Local storage for unverified services (in real app, use shared preferences or local DB)
  // This stores services locally when the backend is unavailable
  static final List<ServiceHistoryModel> _localServiceHistory = [];

  // HTTP client configuration
  Map<String, String> _getHeaders({String? token}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // Get all service history records for a vehicle (both verified and unverified)
  Future<List<ServiceHistoryModel>> getServiceHistory(int vehicleId,
      {String? token}) async {
    try {
      // Get verified services from API using the correct endpoint
      final url = ApiConfig.getVehicleServiceHistoryUrl(vehicleId);
      print('🔍 Fetching service history from: $url');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .get(
            Uri.parse(url),
            headers: _getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📡 Response status: ${response.statusCode}');

      List<ServiceHistoryModel> verifiedServices = [];
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        verifiedServices =
            data.map((json) => ServiceHistoryModel.fromJson(json)).toList();
        print(
            '✅ Retrieved ${verifiedServices.length} verified services from backend');
      } else if (response.statusCode != 404) {
        // 404 is OK (no data), other errors should be logged
        print('⚠️ API Error ${response.statusCode}: ${response.body}');
      } else {
        print('📭 No verified services found (404 - OK)');
      }

      // Get unverified services from local storage
      final unverifiedServices = _localServiceHistory
          .where((service) => service.vehicleId == vehicleId)
          .toList();

      print(
          '💾 Found ${unverifiedServices.length} unverified services locally');

      // Combine both lists and sort by date (newest first)
      final allServices = [...verifiedServices, ...unverifiedServices];
      allServices.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));

      print(
          '📊 Total services: ${allServices.length} (${verifiedServices.length} verified + ${unverifiedServices.length} unverified)');
      return allServices;
    } catch (e) {
      print('❌ Error getting service history: $e');
      // Return only local services if API fails
      final localServices = _localServiceHistory
          .where((service) => service.vehicleId == vehicleId)
          .toList()
        ..sort((a, b) => b.serviceDate.compareTo(a.serviceDate));

      print('🔄 Falling back to ${localServices.length} local services only');
      return localServices;
    }
  }

  // Add verified service record (to API)
  Future<bool> addVerifiedService(ServiceHistoryModel service,
      {String? token}) async {
    try {
      print('🔧 Attempting to add service via API...');
      print(
          '   URL: ${ApiConfig.createVehicleServiceHistoryUrl(service.vehicleId)}');
      print('   JSON: ${json.encode(service.toCreateJson())}');

      final response = await http
          .post(
            Uri.parse(
                ApiConfig.createVehicleServiceHistoryUrl(service.vehicleId)),
            headers: _getHeaders(token: token),
            body: json.encode(service.toCreateJson()),
          )
          .timeout(ApiConfig.connectTimeout);

      print('   Response Status: ${response.statusCode}');
      print('   Response Headers: ${response.headers}');
      print('   Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Service added successfully via API');
        return true;
      } else {
        print('❌ API Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Exception adding verified service: $e');
      return false;
    }
  }

  // Add unverified service record (try backend first, fallback to local storage)
  Future<bool> addUnverifiedService(ServiceHistoryModel service,
      {String? token}) async {
    try {
      print('🔧 Attempting to add unverified service...');

      // Create a backend-ready version of the service
      // Mark as unverified since it's from external service center
      final backendService = service.copyWith(
        isVerified: false, // Mark as unverified for backend
        serviceCenterId: null, // No registered service center
        servicedByUserId: null, // No registered technician
      );

      // First, try to send to backend
      final backendSuccess =
          await addVerifiedService(backendService, token: token);

      if (backendSuccess) {
        print('✅ Unverified service successfully sent to backend');
        return true;
      } else {
        print('⚠️ Backend failed, storing locally as fallback');

        // Fallback: Store locally if backend fails
        final unverifiedService = service.copyWith(
          serviceHistoryId: _generateLocalId(),
          isVerified: false,
        );

        _localServiceHistory.add(unverifiedService);
        print('✅ Service stored locally as unverified');
        return true;
      }
    } catch (e) {
      print('❌ Error adding unverified service: $e');

      // Fallback: Store locally if exception occurs
      try {
        final unverifiedService = service.copyWith(
          serviceHistoryId: _generateLocalId(),
          isVerified: false,
        );

        _localServiceHistory.add(unverifiedService);
        print('✅ Service stored locally as fallback after exception');
        return true;
      } catch (localError) {
        print('❌ Failed to store locally: $localError');
        return false;
      }
    }
  }

  // Add unverified service locally only (for testing/offline mode)
  Future<bool> addUnverifiedServiceLocalOnly(
      ServiceHistoryModel service) async {
    try {
      final unverifiedService = service.copyWith(
        serviceHistoryId: _generateLocalId(),
        isVerified: false,
      );

      _localServiceHistory.add(unverifiedService);
      print('✅ Service stored locally only');
      return true;
    } catch (e) {
      print('❌ Error storing service locally: $e');
      return false;
    }
  }

  // Update service record
  Future<bool> updateService(ServiceHistoryModel service,
      {String? token}) async {
    try {
      if (service.isVerified && service.serviceHistoryId != null) {
        // Update verified service via API
        final response = await http
            .put(
              Uri.parse(ApiConfig.updateVehicleServiceHistoryUrl(
                  service.vehicleId, service.serviceHistoryId!)),
              headers: _getHeaders(token: token),
              body: json.encode(service.toUpdateJson()),
            )
            .timeout(ApiConfig.connectTimeout);

        if (response.statusCode == 200 || response.statusCode == 204) {
          return true;
        } else {
          print('API Error ${response.statusCode}: ${response.body}');
          return false;
        }
      } else {
        // Update unverified service in local storage
        final index = _localServiceHistory
            .indexWhere((s) => s.serviceHistoryId == service.serviceHistoryId);
        if (index != -1) {
          _localServiceHistory[index] = service;
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error updating service: $e');
      return false;
    }
  }

  // Delete service record
  Future<bool> deleteService(ServiceHistoryModel service,
      {String? token}) async {
    try {
      if (service.isVerified && service.serviceHistoryId != null) {
        // Delete verified service via API
        final response = await http
            .delete(
              Uri.parse(ApiConfig.deleteVehicleServiceHistoryUrl(
                  service.vehicleId, service.serviceHistoryId!)),
              headers: _getHeaders(token: token),
            )
            .timeout(ApiConfig.connectTimeout);

        if (response.statusCode == 200 || response.statusCode == 204) {
          return true;
        } else {
          print('API Error ${response.statusCode}: ${response.body}');
          return false;
        }
      } else {
        // Delete unverified service from local storage
        _localServiceHistory
            .removeWhere((s) => s.serviceHistoryId == service.serviceHistoryId);
        return true;
      }
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  // Get service by ID
  Future<ServiceHistoryModel?> getServiceById(
      int vehicleId, int serviceHistoryId,
      {String? token}) async {
    try {
      // Check local storage first
      final localService = _localServiceHistory
          .where((service) => service.serviceHistoryId == serviceHistoryId)
          .toList();

      if (localService.isNotEmpty) {
        return localService.first;
      }

      // Check API for verified services
      final response = await http
          .get(
            Uri.parse(ApiConfig.getVehicleServiceHistoryByIdUrl(
                vehicleId, serviceHistoryId)),
            headers: _getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceHistoryModel.fromJson(data);
      } else {
        print('API Error ${response.statusCode}: ${response.body}');
      }

      return null;
    } catch (e) {
      print('Error getting service by ID: $e');
      return null;
    }
  }

  // Generate local ID for unverified services (negative to avoid conflicts)
  int _generateLocalId() {
    if (_localServiceHistory.isEmpty) {
      return -1; // Start local IDs from -1 and go down
    }
    final minId = _localServiceHistory
        .map((service) => service.serviceHistoryId ?? 0)
        .where((id) => id < 0)
        .fold(0, (a, b) => a < b ? a : b);
    return minId - 1;
  }

  // Get summary statistics
  Future<Map<String, dynamic>> getServiceStatistics(int vehicleId,
      {String? token}) async {
    try {
      final services = await getServiceHistory(vehicleId, token: token);
      final verifiedCount = services.where((s) => s.isVerified).length;
      final unverifiedCount = services.where((s) => !s.isVerified).length;
      final totalCost = services
          .where((s) => s.cost != null)
          .fold(0.0, (sum, service) => sum + (service.cost ?? 0));

      return {
        'totalServices': services.length,
        'verifiedServices': verifiedCount,
        'unverifiedServices': unverifiedCount,
        'totalCost': totalCost,
        'lastServiceDate':
            services.isNotEmpty ? services.first.serviceDate : null,
      };
    } catch (e) {
      print('Error getting service statistics: $e');
      return {
        'totalServices': 0,
        'verifiedServices': 0,
        'unverifiedServices': 0,
        'totalCost': 0.0,
        'lastServiceDate': null,
      };
    }
  }

  // Test backend connection
  Future<bool> testConnection({String? token, int? testVehicleId}) async {
    try {
      // Test backend connectivity by trying to access service history for a vehicle
      // If no testVehicleId is provided, use a default one just for connection testing
      final vehicleIdForTest = testVehicleId ?? 1;
      final url = ApiConfig.getVehicleServiceHistoryUrl(vehicleIdForTest);

      print('🔍 Testing backend connection to: $url');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .get(
            Uri.parse(url),
            headers: _getHeaders(token: token),
          )
          .timeout(const Duration(seconds: 5));

      print('📡 Connection test response: ${response.statusCode}');

      // Accept 200 (success), 404 (no data), or 401 (unauthorized but server is up)
      // These all indicate the server is reachable and responding
      final isConnected = response.statusCode == 200 ||
          response.statusCode == 404 ||
          response.statusCode == 401;

      print('🌐 Backend connection: ${isConnected ? "✅ Success" : "❌ Failed"}');
      return isConnected;
    } catch (e) {
      print('❌ Backend connection test failed: $e');
      return false;
    }
  }

  // Test backend connection using customer's actual vehicle
  Future<bool> testConnectionWithVehicle(int vehicleId, {String? token}) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getVehicleServiceHistoryUrl(vehicleId)),
            headers: _getHeaders(token: token),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200 ||
          response.statusCode == 404 ||
          response.statusCode == 401;
    } catch (e) {
      print('Backend connection test failed: $e');
      return false;
    }
  }

  // Sync unverified services to backend (future feature)
  Future<bool> syncUnverifiedServices(int vehicleId, {String? token}) async {
    try {
      bool allSynced = true;
      final unverifiedServices = _localServiceHistory
          .where((service) =>
              !service.isVerified && service.vehicleId == vehicleId)
          .toList();

      for (final service in unverifiedServices) {
        // Convert to verified service and sync
        final verifiedService = service.copyWith(
          isVerified: true,
          serviceHistoryId: null, // Let backend assign ID
        );

        final success = await addVerifiedService(verifiedService, token: token);
        if (success) {
          // Remove from local storage
          _localServiceHistory.removeWhere(
              (s) => s.serviceHistoryId == service.serviceHistoryId);
        } else {
          allSynced = false;
        }
      }
      return allSynced;
    } catch (e) {
      print('Error syncing unverified services: $e');
      return false;
    }
  }

  // Clear local cache (for testing purposes)
  void clearLocalCache() {
    _localServiceHistory.clear();
  }

  // Get local unverified services count
  int getLocalUnverifiedCount(int vehicleId) {
    return _localServiceHistory
        .where(
            (service) => !service.isVerified && service.vehicleId == vehicleId)
        .length;
  }

  // Debug utility to check URL construction
  String getServiceHistoryUrlForVehicle(int vehicleId) {
    final url = ApiConfig.getVehicleServiceHistoryUrl(vehicleId);
    print('🔧 Service History URL for vehicle $vehicleId: $url');
    return url;
  }

  // Get the preview URL for service history PDF
  String getServiceHistoryPdfPreviewUrl(int vehicleId) {
    return ApiConfig.getServiceHistoryPdfPreviewUrl(vehicleId);
  }

  // Download service history PDF for a vehicle (updated to use new endpoint)
  Future<Uint8List> downloadServiceHistoryPdf(int vehicleId,
      {String? token}) async {
    final url = ApiConfig.getServiceHistoryPdfDownloadUrl(vehicleId);
    print('📄 Downloading service history PDF from: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(token: token),
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('❌ Failed to download PDF: ${response.statusCode}');
      throw Exception('Failed to download PDF');
    }
  }
}
