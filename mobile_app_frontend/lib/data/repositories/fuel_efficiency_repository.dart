import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/fuel_efficiency_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FuelEfficiencyRepository {
  // HTTP client configuration
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Get all fuel efficiency records for a vehicle
  Future<List<FuelEfficiencyModel>> getFuelRecords(int vehicleId) async {
    try {
      final url = ApiConfig.getFuelEfficienciesByVehicleUrl(vehicleId);
      print('🔍 Getting fuel records for vehicle $vehicleId');
      print('🔗 URL: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('📊 Raw data count: ${data.length}');

        final apiRecords =
            data.map((json) => FuelEfficiencyModel.fromJson(json)).toList();

        print('✅ Loaded ${apiRecords.length} fuel records from API');

        // Debug: Show latest record if available
        if (apiRecords.isNotEmpty) {
          final latest = apiRecords.last;
          print(
              '📋 Latest record: ID=${latest.fuelEfficiencyId}, Date=${latest.date}, Amount=${latest.fuelAmount}');
        }

        return apiRecords;
      } else if (response.statusCode == 404) {
        print('ℹ️ No fuel records found for vehicle $vehicleId');
        return [];
      } else {
        print('❌ API Error ${response.statusCode}: ${response.body}');
        return await _getLocalFuelRecords(vehicleId);
      }
    } catch (e) {
      print('❌ Error getting fuel records: $e');
      // Fallback to local storage
      return await _getLocalFuelRecords(vehicleId);
    }
  }

  // Add fuel efficiency record
  Future<bool> addFuelRecord(FuelEfficiencyModel fuelRecord) async {
    try {
      print('📝 Adding fuel record via API...');
      print('🔗 URL: ${ApiConfig.addFuelEfficiencyUrl()}');

      final jsonData = json.encode(fuelRecord.toCreateJson());
      print('📊 Data being sent: $jsonData');

      // Parse and check the date specifically
      final dataMap = fuelRecord.toCreateJson();
      print(
          '📅 Date being sent: ${dataMap['Date']} (${dataMap['Date'].runtimeType})'); // Updated to use 'Date' field

      final response = await http
          .post(
            Uri.parse(ApiConfig.addFuelEfficiencyUrl()),
            headers: _headers,
            body: json.encode(fuelRecord.toCreateJson()),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Fuel record added successfully');

        // Parse response to get the created record ID
        if (response.body.isNotEmpty) {
          try {
            final responseData = json.decode(response.body);
            print('📋 Created record data: $responseData');
          } catch (e) {
            print('⚠️ Could not parse response data: $e');
          }
        }

        return true;
      } else {
        print(
            '❌ Failed to add fuel record: ${response.statusCode} - ${response.body}');
        // Fallback to local storage
        await _addLocalFuelRecord(fuelRecord);
        return false;
      }
    } catch (e) {
      print('❌ Error adding fuel record: $e');
      // Fallback to local storage
      await _addLocalFuelRecord(fuelRecord);
      return false;
    }
  }

  // Update fuel efficiency record
  Future<bool> updateFuelRecord(int id, FuelEfficiencyModel fuelRecord) async {
    try {
      print('✏️ Updating fuel record $id via API...');

      final response = await http
          .put(
            Uri.parse(ApiConfig.updateFuelEfficiencyUrl(id)),
            headers: _headers,
            body: json.encode(fuelRecord.toUpdateJson()),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ Fuel record updated successfully');
        return true;
      } else {
        print(
            '❌ Failed to update fuel record: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating fuel record: $e');
      return false;
    }
  }

  // Delete fuel efficiency record
  Future<bool> deleteFuelRecord(int id) async {
    try {
      print('🗑️ Deleting fuel record $id via API...');

      final response = await http
          .delete(
            Uri.parse(ApiConfig.deleteFuelEfficiencyUrl(id)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ Fuel record deleted successfully');
        return true;
      } else {
        print(
            '❌ Failed to delete fuel record: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting fuel record: $e');
      return false;
    }
  }

  // Get fuel efficiency summary
  Future<FuelEfficiencySummaryModel?> getFuelSummary(int vehicleId,
      {int? year}) async {
    try {
      print('📊 Getting fuel summary for vehicle $vehicleId');

      final response = await http
          .get(
            Uri.parse(
                ApiConfig.getFuelEfficiencySummaryUrl(vehicleId, year: year)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FuelEfficiencySummaryModel.fromJson(data);
      } else {
        print('❌ Failed to get fuel summary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting fuel summary: $e');
      return null;
    }
  }

  // Get monthly chart data
  Future<List<MonthlyFuelSummaryModel>> getMonthlyChartData(
      int vehicleId, int year) async {
    try {
      print('📈 Getting monthly chart data for vehicle $vehicleId, year $year');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getMonthlyChartDataUrl(vehicleId, year)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => MonthlyFuelSummaryModel.fromJson(json))
            .toList();
      } else {
        print('❌ Failed to get monthly chart data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting monthly chart data: $e');
      return [];
    }
  }

  // Get monthly fuel records
  Future<List<FuelEfficiencyModel>> getMonthlyFuelRecords(
      int vehicleId, int year, int month) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                ApiConfig.getMonthlyFuelRecordsUrl(vehicleId, year, month)),
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => FuelEfficiencyModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error getting monthly fuel records: $e');
      return [];
    }
  }

  // Test backend connection
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getFuelEfficienciesByVehicleUrl(
                ApiConfig.defaultVehicleId)),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      print('Backend connection test failed: $e');
      return false;
    }
  }

  // Local storage methods (fallback when API is unavailable)
  Future<List<FuelEfficiencyModel>> _getLocalFuelRecords(int vehicleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = prefs.getStringList('fuel_records_$vehicleId') ?? [];

      return records
          .map((record) => FuelEfficiencyModel.fromJson(json.decode(record)))
          .where((record) => record.vehicleId == vehicleId)
          .toList()
        ..sort((a, b) => b.fuelDate.compareTo(a.fuelDate));
    } catch (e) {
      print('Error loading local fuel records: $e');
      return [];
    }
  }

  Future<void> _addLocalFuelRecord(FuelEfficiencyModel fuelRecord) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records =
          prefs.getStringList('fuel_records_${fuelRecord.vehicleId}') ?? [];

      // Create a record with a temporary negative ID for local storage
      final localRecord = fuelRecord.copyWith(
        fuelEfficiencyId: -DateTime.now().millisecondsSinceEpoch,
      );

      records.add(json.encode(localRecord.toJson()));
      await prefs.setStringList(
          'fuel_records_${fuelRecord.vehicleId}', records);
      print('💾 Fuel record saved locally');
    } catch (e) {
      print('Error saving local fuel record: $e');
    }
  }

  // Calculate monthly summary from records (for backward compatibility with existing UI)
  Map<String, double> calculateMonthlySummary(
      List<FuelEfficiencyModel> records) {
    final Map<String, double> summary = {};

    for (var record in records) {
      final monthKey =
          '${record.fuelDate.year}-${record.fuelDate.month.toString().padLeft(2, '0')}';
      summary[monthKey] = (summary[monthKey] ?? 0) + record.fuelAmount;
    }

    return summary;
  }
}
