import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/models/vehicle_transfer.dart';

class VehicleTransferService {
  final String _baseUrl = 'http://192.168.1.4:5039/api';

  /// Initiate a vehicle transfer to another user
  Future<Map<String, dynamic>> initiateTransfer({
    required int vehicleId,
    required String buyerEmail,
    required int sellerId,
    int? mileageAtTransfer,
    double? salePrice,
    String? notes,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/VehicleTransfer/initiate?sellerId=$sellerId');

      final payload = {
        'vehicleId': vehicleId,
        'buyerEmail': buyerEmail,
        'mileageAtTransfer': mileageAtTransfer,
        'salePrice': salePrice,
        'notes': notes,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Transfer initiated: ${data['message']}');
        return {
          'success': true,
          'message': data['message'],
          'transfer': data['transfer'] != null ? VehicleTransfer.fromJson(data['transfer']) : null,
        };
      } else {
        final error = jsonDecode(response.body);
        print('❌ Transfer initiation failed: ${error['message']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to initiate transfer',
        };
      }
    } catch (e) {
      print('❌ Error initiating transfer: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Accept a pending vehicle transfer
  Future<Map<String, dynamic>> acceptTransfer({
    required int transferId,
    required int buyerId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/VehicleTransfer/accept/$transferId?buyerId=$buyerId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Transfer accepted: ${data['message']}');
        return {
          'success': true,
          'message': data['message'],
          'transfer': data['transfer'] != null ? VehicleTransfer.fromJson(data['transfer']) : null,
        };
      } else {
        final error = jsonDecode(response.body);
        print('❌ Transfer acceptance failed: ${error['message']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to accept transfer',
        };
      }
    } catch (e) {
      print('❌ Error accepting transfer: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Reject a pending vehicle transfer
  Future<Map<String, dynamic>> rejectTransfer({
    required int transferId,
    required int buyerId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/VehicleTransfer/reject/$transferId?buyerId=$buyerId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Transfer rejected: ${data['message']}');
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        print('❌ Transfer rejection failed: ${error['message']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to reject transfer',
        };
      }
    } catch (e) {
      print('❌ Error rejecting transfer: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Cancel a pending vehicle transfer (seller only)
  Future<Map<String, dynamic>> cancelTransfer({
    required int transferId,
    required int sellerId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/VehicleTransfer/cancel/$transferId?sellerId=$sellerId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Transfer cancelled: ${data['message']}');
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        print('❌ Transfer cancellation failed: ${error['message']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to cancel transfer',
        };
      }
    } catch (e) {
      print('❌ Error cancelling transfer: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Get all pending transfers for a buyer
  Future<List<VehicleTransfer>> getPendingTransfers(int customerId) async {
    try {
      final url = Uri.parse('$_baseUrl/VehicleTransfer/pending/$customerId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VehicleTransfer.fromJson(json)).toList();
      } else {
        print('❌ Failed to get pending transfers: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting pending transfers: $e');
      return [];
    }
  }

  /// Get transfer history for a vehicle
  Future<List<VehicleTransfer>> getTransferHistory(int vehicleId) async {
    try {
      final url = Uri.parse('$_baseUrl/VehicleTransfer/history/$vehicleId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VehicleTransfer.fromJson(json)).toList();
      } else {
        print('❌ Failed to get transfer history: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting transfer history: $e');
      return [];
    }
  }
}
