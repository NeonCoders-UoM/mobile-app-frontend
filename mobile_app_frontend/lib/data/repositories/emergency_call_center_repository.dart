import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/emergency_call_center_model.dart';

class EmergencyCallCenterRepository {
  // HTTP client configuration with optional token
  Map<String, String> _getHeaders({String? token}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // Get all emergency call centers
  Future<List<EmergencyCallCenterModel>> getAllEmergencyCallCenters(
      {String? token}) async {
    try {
      final url = ApiConfig.getAllEmergencyCallCentersUrl();
      print('🚨 Getting all emergency call centers');
      print('🔗 URL: $url');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .get(
            Uri.parse(url),
            headers: _getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('🎯 Found ${data.length} emergency call centers');

        return data
            .map((json) => EmergencyCallCenterModel.fromJson(json))
            .toList();
      } else {
        print('❌ Error getting emergency call centers: ${response.statusCode}');
        print('📝 Response body: ${response.body}');

        // Return empty list as fallback
        return [];
      }
    } catch (e) {
      print('🚨 Exception in getAllEmergencyCallCenters: $e');

      // Return hardcoded fallback data for development/testing
      return _getFallbackEmergencyCallCenters();
    }
  }

  // Test connection to emergency call center API
  Future<bool> testConnection({String? token}) async {
    try {
      print('🧪 Testing emergency call center API connection');
      print('🔑 Using token: ${token != null ? "✅ Yes" : "❌ No"}');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getAllEmergencyCallCentersUrl()),
            headers: _getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📊 Test connection response: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Emergency call center API connection successful');
        return true;
      } else {
        print(
            '❌ Emergency call center API connection failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('🚨 Exception in testConnection: $e');
      return false;
    }
  }

  // Fallback data for development/testing when backend is not available
  List<EmergencyCallCenterModel> _getFallbackEmergencyCallCenters() {
    print('🔄 Using fallback emergency call center data');

    return [
      EmergencyCallCenterModel(
        emergencyCallCenterId: 1,
        name: 'Adonz Automotive',
        address: 'Moratuwa, Sri Lanka',
        registrationNumber: 'REG001',
        phoneNumber: '+94703681620',
      ),
      EmergencyCallCenterModel(
        emergencyCallCenterId: 2,
        name: 'Quick Fix Auto Service',
        address: 'Colombo, Sri Lanka',
        registrationNumber: 'REG002',
        phoneNumber: '+94771234567',
      ),
      EmergencyCallCenterModel(
        emergencyCallCenterId: 3,
        name: '24/7 Emergency Garage',
        address: 'Kandy, Sri Lanka',
        registrationNumber: 'REG003',
        phoneNumber: '+94777654321',
      ),
    ];
  }

  // Get specific emergency call center by ID (if needed for future expansion)
  Future<EmergencyCallCenterModel?> getEmergencyCallCenterById(int id,
      {String? token}) async {
    try {
      final centers = await getAllEmergencyCallCenters(token: token);
      return centers
          .where((center) => center.emergencyCallCenterId == id)
          .firstOrNull;
    } catch (e) {
      print('🚨 Exception in getEmergencyCallCenterById: $e');
      return null;
    }
  }

  // Get emergency call centers by location (future expansion)
  Future<List<EmergencyCallCenterModel>> getEmergencyCallCentersByLocation(
      String location,
      {String? token}) async {
    try {
      final centers = await getAllEmergencyCallCenters(token: token);
      return centers
          .where((center) =>
              center.address.toLowerCase().contains(location.toLowerCase()))
          .toList();
    } catch (e) {
      print('🚨 Exception in getEmergencyCallCentersByLocation: $e');
      return [];
    }
  }
}
