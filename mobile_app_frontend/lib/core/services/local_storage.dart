import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _customerIdKey = 'customer_id';
  static const String _paymentVehicleIdKey = 'payment_vehicle_id';
  static const String _paymentCustomerEmailKey = 'payment_customer_email';
  static const String _paymentCustomerNameKey = 'payment_customer_name';

  // Save authentication data
  static Future<void> saveAuthData({
    required String token,
    required int customerId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_customerIdKey, customerId);
    print(
        '💾 Auth data saved: Token=${token.substring(0, 10)}..., CustomerId=$customerId');
  }

  // Retrieve authentication data
  static Future<Map<String, dynamic>?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final customerId = prefs.getInt(_customerIdKey);

    if (token != null && customerId != null) {
      print(
          '📱 Auth data retrieved: Token=${token.substring(0, 10)}..., CustomerId=$customerId');
      return {
        'token': token,
        'customerId': customerId,
      };
    }

    // Removed debug print to avoid confusion
    return null;
  }

  // Save payment context data
  static Future<void> savePaymentContext({
    required int vehicleId,
    required String customerEmail,
    required String customerName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_paymentVehicleIdKey, vehicleId);
    await prefs.setString(_paymentCustomerEmailKey, customerEmail);
    await prefs.setString(_paymentCustomerNameKey, customerName);
    print(
        '💾 Payment context saved: VehicleId=$vehicleId, Email=$customerEmail');
  }

  // Retrieve payment context data
  static Future<Map<String, dynamic>?> getPaymentContext() async {
    final prefs = await SharedPreferences.getInstance();
    final vehicleId = prefs.getInt(_paymentVehicleIdKey);
    final customerEmail = prefs.getString(_paymentCustomerEmailKey);
    final customerName = prefs.getString(_paymentCustomerNameKey);

    if (vehicleId != null && customerEmail != null && customerName != null) {
      print(
          '📱 Payment context retrieved: VehicleId=$vehicleId, Email=$customerEmail');
      return {
        'vehicleId': vehicleId,
        'customerEmail': customerEmail,
        'customerName': customerName,
      };
    }

    // Removed debug print to avoid confusion
    return null;
  }

  // Clear payment context data
  static Future<void> clearPaymentContext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_paymentVehicleIdKey);
    await prefs.remove(_paymentCustomerEmailKey);
    await prefs.remove(_paymentCustomerNameKey);
    print('🗑️ Payment context cleared');
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_customerIdKey);
    print('🗑️ Auth data cleared');
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final authData = await getAuthData();
    return authData != null &&
        authData['token'] != null &&
        authData['token'].isNotEmpty;
  }
}
