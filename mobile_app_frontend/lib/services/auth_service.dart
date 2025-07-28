import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://192.168.8.186:5039/api';

  Future<bool> registerCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$_baseUrl/Auth/register-customer');

    final Map<String, dynamic> payload = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "address": "To be updated", // temporary
      "phoneNumber": phoneNumber,
      "nic": "To be updated", // temporary
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('✅ Registered: ${response.body}');
      return true;
    } else {
      print('❌ Register failed: ${response.body}');
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$_baseUrl/Auth/verify-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Verify OTP failed: ${response.statusCode} ${response.body}');
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    final url = Uri.parse('$_baseUrl/Auth/resend-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(email),
    );

    return response.statusCode == 200;
  }

  Future<int> updateCustomer({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String nic,
    required String address,
  }) async {
    final response = await http.put(
      Uri.parse("$_baseUrl/Auth/update-customer-details"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "nic": nic,
        "address": address,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["customerId"];
    } else {
      throw Exception("Failed to update details: ${response.body}");
    }
  }

  Future<Map<String, dynamic>?> getCustomerDetails({
    required int customerId,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/Customers/$customerId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔑 GET Customer Details for CustomerID: $customerId');
      print('🔐 Using Token: $token');
      print('🔍 Response Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Customer details fetched: $data');
        return data;
      } else {
        print(
            '❌ Failed to fetch customer details: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching customer details: $e');
      return null;
    }
  }

  Future<bool> updateCustomerProfile({
    required int customerId,
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String nic,
    required String address,
  }) async {
    final url = Uri.parse('$_baseUrl/Auth/update-customer-details');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "firstName": firstName,
          "lastName": lastName,
          "phoneNumber": phoneNumber,
          "nic": nic,
          "address": address,
        }),
      );

      print('🔑 UPDATE Customer Profile for CustomerID: $customerId');
      print('🔐 Using Token: $token');
      print('🔍 Response Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Customer profile updated successfully');
        return true;
      } else {
        print(
            '❌ Failed to update customer profile: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating customer profile: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginCustomer({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/Auth/login-customer');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final customerId =
          data['customerId']; // Make sure your backend returns this!

      // Save token if you want
      return {
        'token': token,
        'customerId': customerId,
      };
    } else {
      return null;
    }
  }

  Future<bool> registerVehicle({
    required int customerId,
    required String registrationNumber,
    required String chassisNumber,
    required String category,
    required String model,
    required String brand,
    required String fuel,
  }) async {
    final url = Uri.parse('$_baseUrl/Customers/$customerId/vehicles');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "registrationNumber": registrationNumber,
        "chassisNumber": chassisNumber,
        "category": category,
        "model": model,
        "brand": brand,
        "fuel": fuel,
        'year': 2025, // Example field
        'mileage': 0 // Example field if needed
      }),
    );

    return response.statusCode == 201;
  }

  Future<List<dynamic>?> getCustomerVehicles({
    required int customerId,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/Customers/$customerId/vehicles');

    print('🔑 GET Vehicles for CustomerID: $customerId');
    print('🔐 Using Token: $token');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('🔍 Response Code: ${response.statusCode}');
    print('🔍 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      print('🚫 Unauthorized - check your token and backend secret key.');
    }

    return null;
  }

  Future<bool> updateVehicle({
    required int customerId,
    required int vehicleId,
    required String token,
    required String registrationNumber,
    required String chassisNumber,
    required String model,
    required String brand,
    required String fuel,
    required int mileage,
    required int year,
  }) async {
    final url =
        Uri.parse('$_baseUrl/Customers/$customerId/vehicles/$vehicleId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "registrationNumber": registrationNumber,
        "chassisNumber": chassisNumber,
        "model": model,
        "brand": brand,
        "fuel": fuel,
        "mileage": mileage,
        "year": year,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteAccount({
    required int customerId,
    required String token,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/Auth/delete-account');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'customerId': customerId,
        'password': password,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteVehicle({
    required int customerId,
    required int vehicleId,
    required String token,
  }) async {
    final url =
        Uri.parse('$_baseUrl/Customers/$customerId/vehicles/$vehicleId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('✅ Vehicle deleted');
      return true;
    } else {
      print(
          '❌ Failed to delete vehicle: ${response.statusCode} ${response.body}');
      return false;
    }
  }

  Future<bool> changePassword({
    required int customerId,
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/Auth/change-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customerId': customerId,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getVehicleById({
    required int customerId,
    required int vehicleId,
    required String token,
  }) async {
    final url =
        Uri.parse('$_baseUrl/Customers/$customerId/vehicles/$vehicleId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('🔑 GET Vehicle by ID: $vehicleId for CustomerID: $customerId');
      print('🔐 Using Token: $token');
      print('🔍 Response Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Vehicle details fetched: $data');
        return data;
      } else {
        print(
            '❌ Failed to fetch vehicle details: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching vehicle details: $e');
      return null;
    }
  }

  // Add verifyOtp() and resendOtp() methods later if needed
}
