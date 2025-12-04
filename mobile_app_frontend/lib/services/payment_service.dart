import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';

/// Payment service for integrating PayHere payment gateway
///
/// Before using this service:
/// 1. Whitelist your app package name in PayHere dashboard
/// 2. Get your Merchant ID and Merchant Secret
/// 3. Update the constants below with your credentials
class PaymentService {
  // TODO: Replace with your actual credentials from PayHere dashboard
  static const String merchantId = "1233023"; // Your Merchant ID
  static const String merchantSecret =
      "NjEyMTA2MDk3Mjg1MDExODAwMjc5NTUwNTk1MjEwNTg3OTg0MA=="; // From PayHere dashboard (verify this matches your app's secret)
  static const bool sandboxMode = true; // Set to false for production
  static const String notifyUrl =
      "https://d2ba38d700ef.ngrok-free.app/api/payhere/notify"; // Your ngrok URL from backend

  /// One-time payment for services
  ///
  /// Example usage:
  /// ```dart
  /// await PaymentService.makeServicePayment(
  ///   orderId: "APT-12345",
  ///   itemDescription: "Vehicle Service",
  ///   amount: 5000.0,
  ///   firstName: "John",
  ///   lastName: "Doe",
  ///   email: "john@example.com",
  ///   phone: "0771234567",
  ///   address: "123 Main St",
  ///   city: "Colombo",
  ///   onSuccess: (paymentId) => print("Success: $paymentId"),
  ///   onError: (error) => print("Error: $error"),
  ///   onDismissed: () => print("Dismissed"),
  /// );
  /// ```
  static Future<void> makeServicePayment({
    required String orderId,
    required String itemDescription,
    required double amount,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String city,
    Function(String)? onSuccess,
    Function(String)? onError,
    Function()? onDismissed,
    String? deliveryAddress,
    String? deliveryCity,
    String? custom1,
    String? custom2,
  }) async {
    Map paymentObject = {
      "sandbox": sandboxMode,
      "merchant_id": merchantId,
      "merchant_secret": merchantSecret,
      "notify_url": notifyUrl,
      "order_id": orderId,
      "items": itemDescription,
      "amount": amount.toStringAsFixed(2),
      "currency": "LKR",
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "address": address,
      "city": city,
      "country": "Sri Lanka",
    };

    // Add optional fields
    if (deliveryAddress != null) {
      paymentObject["delivery_address"] = deliveryAddress;
    }
    if (deliveryCity != null) {
      paymentObject["delivery_city"] = deliveryCity;
      paymentObject["delivery_country"] = "Sri Lanka";
    }
    if (custom1 != null) paymentObject["custom_1"] = custom1;
    if (custom2 != null) paymentObject["custom_2"] = custom2;

    try {
      PayHere.startPayment(
        paymentObject,
        (paymentId) {
          print("Payment Success! Payment ID: $paymentId");
          onSuccess?.call(paymentId);
        },
        (error) {
          print("Payment Failed. Error: $error");
          onError?.call(error);
        },
        () {
          print("Payment Dismissed");
          onDismissed?.call();
        },
      );
    } catch (e) {
      print("Error initiating payment: $e");
      onError?.call(e.toString());
    }
  }

  /// Payment with itemized details
  ///
  /// Example usage:
  /// ```dart
  /// List<PaymentItem> items = [
  ///   PaymentItem(itemNumber: "SRV001", name: "Oil Change", amount: 5000.0, quantity: 1),
  ///   PaymentItem(itemNumber: "PART001", name: "Air Filter", amount: 2000.0, quantity: 2),
  /// ];
  ///
  /// CustomerInfo customer = CustomerInfo(
  ///   firstName: "Jane",
  ///   lastName: "Smith",
  ///   email: "jane@example.com",
  ///   phone: "0771234567",
  ///   address: "456 Road",
  ///   city: "Kandy",
  /// );
  ///
  /// await PaymentService.makeItemizedPayment(
  ///   orderId: "ORD-12345",
  ///   items: items,
  ///   totalAmount: 9000.0,
  ///   customerInfo: customer,
  /// );
  /// ```
  static Future<void> makeItemizedPayment({
    required String orderId,
    required List<PaymentItem> items,
    required double totalAmount,
    required CustomerInfo customerInfo,
    Function(String)? onSuccess,
    Function(String)? onError,
    Function()? onDismissed,
    String? deliveryAddress,
    String? deliveryCity,
  }) async {
    Map paymentObject = {
      "sandbox": sandboxMode,
      "merchant_id": merchantId,
      "merchant_secret": merchantSecret,
      "notify_url": notifyUrl,
      "order_id": orderId,
      "items": "Vehicle Service Payment",
      "amount": totalAmount.toStringAsFixed(2),
      "currency": "LKR",
      "first_name": customerInfo.firstName,
      "last_name": customerInfo.lastName,
      "email": customerInfo.email,
      "phone": customerInfo.phone,
      "address": customerInfo.address,
      "city": customerInfo.city,
      "country": "Sri Lanka",
    };

    // Add itemized details
    for (int i = 0; i < items.length; i++) {
      int index = i + 1;
      paymentObject["item_number_$index"] = items[i].itemNumber;
      paymentObject["item_name_$index"] = items[i].name;
      paymentObject["amount_$index"] = items[i].amount.toStringAsFixed(2);
      paymentObject["quantity_$index"] = items[i].quantity.toString();
    }

    // Add optional delivery info
    if (deliveryAddress != null) {
      paymentObject["delivery_address"] = deliveryAddress;
    }
    if (deliveryCity != null) {
      paymentObject["delivery_city"] = deliveryCity;
      paymentObject["delivery_country"] = "Sri Lanka";
    }

    try {
      PayHere.startPayment(
        paymentObject,
        (paymentId) {
          print("Itemized Payment Success! Payment ID: $paymentId");
          onSuccess?.call(paymentId);
        },
        (error) {
          print("Itemized Payment Failed. Error: $error");
          onError?.call(error);
        },
        () {
          print("Itemized Payment Dismissed");
          onDismissed?.call();
        },
      );
    } catch (e) {
      print("Error initiating itemized payment: $e");
      onError?.call(e.toString());
    }
  }

  /// Recurring payment for subscriptions (e.g., monthly service packages)
  ///
  /// Example usage:
  /// ```dart
  /// await PaymentService.makeRecurringPayment(
  ///   orderId: "SUB-12345",
  ///   description: "Monthly Maintenance Package",
  ///   recurringAmount: 10000.0,
  ///   recurrence: "1 Month",
  ///   duration: "1 Year",
  ///   startupFee: 5000.0,
  ///   customerInfo: customer,
  /// );
  /// ```
  static Future<void> makeRecurringPayment({
    required String orderId,
    required String description,
    required double recurringAmount,
    required String recurrence, // e.g., "1 Month", "1 Week", "1 Year"
    required String duration, // e.g., "1 Year", "6 Months", "Forever"
    double startupFee = 0.0,
    required CustomerInfo customerInfo,
    Function(String)? onSuccess,
    Function(String)? onError,
    Function()? onDismissed,
  }) async {
    Map paymentObject = {
      "sandbox": sandboxMode,
      "merchant_id": merchantId,
      "merchant_secret": merchantSecret,
      "notify_url": notifyUrl,
      "order_id": orderId,
      "items": description,
      "amount": recurringAmount.toStringAsFixed(2),
      "recurrence": recurrence,
      "duration": duration,
      "startup_fee": startupFee.toStringAsFixed(2),
      "currency": "LKR",
      "first_name": customerInfo.firstName,
      "last_name": customerInfo.lastName,
      "email": customerInfo.email,
      "phone": customerInfo.phone,
      "address": customerInfo.address,
      "city": customerInfo.city,
      "country": "Sri Lanka",
    };

    try {
      PayHere.startPayment(
        paymentObject,
        (paymentId) {
          print("Recurring Payment Success! Payment ID: $paymentId");
          onSuccess?.call(paymentId);
        },
        (error) {
          print("Recurring Payment Failed. Error: $error");
          onError?.call(error);
        },
        () {
          print("Recurring Payment Dismissed");
          onDismissed?.call();
        },
      );
    } catch (e) {
      print("Error initiating recurring payment: $e");
      onError?.call(e.toString());
    }
  }

  /// Hold-on-Card (Authorization) - Hold charges for later capture
  /// Use PayHere Capture API from backend to capture the held amount
  ///
  /// Example usage:
  /// ```dart
  /// await PaymentService.authorizePayment(
  ///   orderId: "AUTH-12345",
  ///   description: "Service Deposit",
  ///   amount: 10000.0,
  ///   customerInfo: customer,
  /// );
  /// ```
  static Future<void> authorizePayment({
    required String orderId,
    required String description,
    required double amount,
    required CustomerInfo customerInfo,
    Function(String)? onSuccess,
    Function(String)? onError,
    Function()? onDismissed,
  }) async {
    Map paymentObject = {
      "sandbox": sandboxMode,
      "authorize": true, // Required for hold-on-card
      "merchant_id": merchantId,
      "merchant_secret": merchantSecret,
      "notify_url": notifyUrl,
      "order_id": orderId,
      "items": description,
      "currency": "LKR",
      "amount": amount.toStringAsFixed(2),
      "first_name": customerInfo.firstName,
      "last_name": customerInfo.lastName,
      "email": customerInfo.email,
      "phone": customerInfo.phone,
      "address": customerInfo.address,
      "city": customerInfo.city,
      "country": "Sri Lanka",
    };

    try {
      PayHere.startPayment(
        paymentObject,
        (paymentId) {
          print("Hold-on-Card Success! Payment ID: $paymentId");
          onSuccess?.call(paymentId);
        },
        (error) {
          print("Hold-on-Card Failed. Error: $error");
          onError?.call(error);
        },
        () {
          print("Hold-on-Card Dismissed");
          onDismissed?.call();
        },
      );
    } catch (e) {
      print("Error initiating hold-on-card: $e");
      onError?.call(e.toString());
    }
  }

  /// Preapproval (Tokenization) - Save card for later charging
  /// Use PayHere Charging API from backend to charge the tokenized card
  ///
  /// Example usage:
  /// ```dart
  /// await PaymentService.tokenizeCard(
  ///   orderId: "TOKEN-12345",
  ///   customerInfo: customer,
  /// );
  /// ```
  static Future<void> tokenizeCard({
    required String orderId,
    required CustomerInfo customerInfo,
    Function(String)? onSuccess,
    Function(String)? onError,
    Function()? onDismissed,
  }) async {
    Map paymentObject = {
      "sandbox": sandboxMode,
      "preapprove": true, // Required for tokenization
      "merchant_id": merchantId,
      "merchant_secret": merchantSecret,
      "notify_url": notifyUrl,
      "order_id": orderId,
      "items": "Card Tokenization",
      "currency": "LKR",
      "first_name": customerInfo.firstName,
      "last_name": customerInfo.lastName,
      "email": customerInfo.email,
      "phone": customerInfo.phone,
      "address": customerInfo.address,
      "city": customerInfo.city,
      "country": "Sri Lanka",
    };

    try {
      PayHere.startPayment(
        paymentObject,
        (paymentId) {
          print("Card Tokenization Success! Payment ID: $paymentId");
          onSuccess?.call(paymentId);
        },
        (error) {
          print("Card Tokenization Failed. Error: $error");
          onError?.call(error);
        },
        () {
          print("Card Tokenization Dismissed");
          onDismissed?.call();
        },
      );
    } catch (e) {
      print("Error tokenizing card: $e");
      onError?.call(e.toString());
    }
  }
}

/// Helper class for payment items
class PaymentItem {
  final String itemNumber;
  final String name;
  final double amount;
  final int quantity;

  PaymentItem({
    required this.itemNumber,
    required this.name,
    required this.amount,
    required this.quantity,
  });

  double get total => amount * quantity;
}

/// Helper class for customer information
class CustomerInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;

  CustomerInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
  });

  /// Create CustomerInfo from a map (useful when getting data from forms)
  factory CustomerInfo.fromMap(Map<String, dynamic> map) {
    return CustomerInfo(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
    );
  }

  /// Convert to map (useful for storing or transmitting data)
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
    };
  }
}
