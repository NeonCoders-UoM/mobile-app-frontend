# PayHere Payment Integration - Complete Setup Guide

## ✅ Setup Completed

### 1. Dependencies Added
- ✅ `payhere_mobilesdk_flutter: ^3.2.0` added to `pubspec.yaml`
- ✅ Flutter dependencies installed (`flutter pub get` completed)

### 2. Android Configuration
- ✅ PayHere Maven repository added to `android/build.gradle`
- ✅ AndroidManifest.xml configured with tools namespace and replace attribute
- ✅ ProGuard rules created at `android/app/proguard-rules.pro`
- ✅ Build configuration updated to use ProGuard rules in release mode

### 3. iOS Configuration
- ⚠️ CocoaPods installation required (only on macOS)
- 📝 Run `pod install` in the `ios` directory when building on macOS

## 📋 Next Steps

### Step 1: Whitelist Your App Package Name
1. Login to your PayHere Merchant Account
2. Navigate to **Settings > Domains & Credentials**
3. Click **'Add Domain/App'** button
4. Select **'App'** from the first dropdown
5. Add your Flutter App package name: `com.example.mobile_app_frontend`
6. **Important**: Take note of the **Merchant Secret hash** value - you'll need this in your code
7. Click **'Request to Approve'**

> **Note**: If using a PayHere Live Merchant Account, your App Package Name must be manually reviewed & approved. Allow up to one business day for this review process.

### Step 2: Get Your Merchant Credentials
You'll need these values for payment integration:
- **Merchant ID**: Get from PayHere dashboard (e.g., "1211149")
- **Merchant Secret**: From Step 1 above (unique hash for this app)
- **Sandbox Mode**: Set to `true` for testing, `false` for production

## 💳 Payment Integration Examples

### Example 1: One-time Payment

Create a payment service file:

```dart
// lib/services/payment_service.dart
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';

class PaymentService {
  // TODO: Replace with your actual credentials from PayHere dashboard
  static const String merchantId = "1211149"; // Your Merchant ID
  static const String merchantSecret = "YOUR_MERCHANT_SECRET_HERE"; // From Step 1
  static const bool sandboxMode = true; // Set to false for production
  
  // One-time payment for service appointments
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
  }) async {
    Map paymentObject = {
      "sandbox": sandboxMode,
      "merchant_id": merchantId,
      "merchant_secret": merchantSecret,
      "notify_url": "https://your-backend-server.com/payhere/notify",
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

    try {
      PayHere.startPayment(
        paymentObject,
        (paymentId) {
          print("Payment Success! Payment ID: $paymentId");
          // TODO: Update your backend about successful payment
          // TODO: Navigate to success screen
        },
        (error) {
          print("Payment Failed. Error: $error");
          // TODO: Show error message to user
        },
        () {
          print("Payment Dismissed");
          // TODO: Handle when user closes payment without completing
        },
      );
    } catch (e) {
      print("Error initiating payment: $e");
    }
  }

  // Payment with itemized details
  static Future<void> makeItemizedPayment({
    required String orderId,
    required List<PaymentItem> items,
    required double totalAmount,
    required CustomerInfo customerInfo,
  }) async {
    Map paymentObject = {
      "sandbox": sandboxMode,
      "merchant_id": merchantId,
      "merchant_secret": merchantSecret,
      "notify_url": "https://your-backend-server.com/payhere/notify",
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

    try {
      PayHere.startPayment(
        paymentObject,
        (paymentId) {
          print("Itemized Payment Success! Payment ID: $paymentId");
          // TODO: Update backend
        },
        (error) {
          print("Itemized Payment Failed. Error: $error");
        },
        () {
          print("Itemized Payment Dismissed");
        },
      );
    } catch (e) {
      print("Error initiating itemized payment: $e");
    }
  }

  // Recurring payment for subscriptions (e.g., monthly service packages)
  static Future<void> makeRecurringPayment({
    required String orderId,
    required String description,
    required double recurringAmount,
    required String recurrence, // e.g., "1 Month", "1 Week"
    required String duration, // e.g., "1 Year", "6 Months"
    double startupFee = 0.0,
    required CustomerInfo customerInfo,
  }) async {
    Map paymentObject = {
      "sandbox": sandboxMode,
      "merchant_id": merchantId,
      "merchant_secret": merchantSecret,
      "notify_url": "https://your-backend-server.com/payhere/notify",
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
          // TODO: Update backend about subscription
        },
        (error) {
          print("Recurring Payment Failed. Error: $error");
        },
        () {
          print("Recurring Payment Dismissed");
        },
      );
    } catch (e) {
      print("Error initiating recurring payment: $e");
    }
  }

  // Hold-on-Card (Authorization) - Hold charges for later capture
  static Future<void> authorizePayment({
    required String orderId,
    required String description,
    required double amount,
    required CustomerInfo customerInfo,
  }) async {
    Map paymentObject = {
      "sandbox": sandboxMode,
      "authorize": true, // Required for hold-on-card
      "merchant_id": merchantId,
      "merchant_secret": merchantSecret,
      "notify_url": "https://your-backend-server.com/payhere/notify",
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
          // TODO: Store authorization for later capture
        },
        (error) {
          print("Hold-on-Card Failed. Error: $error");
        },
        () {
          print("Hold-on-Card Dismissed");
        },
      );
    } catch (e) {
      print("Error initiating hold-on-card: $e");
    }
  }

  // Preapproval (Tokenization) - Save card for later charging
  static Future<void> tokenizeCard({
    required String orderId,
    required CustomerInfo customerInfo,
  }) async {
    Map paymentObject = {
      "sandbox": sandboxMode,
      "preapprove": true, // Required for tokenization
      "merchant_id": merchantId,
      "merchant_secret": merchantSecret,
      "notify_url": "https://your-backend-server.com/payhere/notify",
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
          // TODO: Save token to backend for future charging
        },
        (error) {
          print("Card Tokenization Failed. Error: $error");
        },
        () {
          print("Card Tokenization Dismissed");
        },
      );
    } catch (e) {
      print("Error tokenizing card: $e");
    }
  }
}

// Helper classes
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
}

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
}
```

### Example 2: Usage in a Widget

```dart
// Example: Appointment Payment Screen
import 'package:flutter/material.dart';
import 'services/payment_service.dart';

class AppointmentPaymentScreen extends StatelessWidget {
  final String appointmentId;
  final double amount;

  const AppointmentPaymentScreen({
    Key? key,
    required this.appointmentId,
    required this.amount,
  }) : super(key: key);

  void _processPayment(BuildContext context) {
    // Get customer info from your app's state/provider
    // This is just an example
    PaymentService.makeServicePayment(
      orderId: "APT-$appointmentId",
      itemDescription: "Vehicle Service Appointment",
      amount: amount,
      firstName: "John",
      lastName: "Doe",
      email: "john.doe@example.com",
      phone: "0771234567",
      address: "No. 123, Galle Road",
      city: "Colombo",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Amount: LKR ${amount.toStringAsFixed(2)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _processPayment(context),
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Example 3: Itemized Service Payment

```dart
// Example: Service payment with multiple items
void payForService() {
  List<PaymentItem> items = [
    PaymentItem(
      itemNumber: "SRV001",
      name: "Oil Change",
      amount: 5000.0,
      quantity: 1,
    ),
    PaymentItem(
      itemNumber: "SRV002",
      name: "Brake Inspection",
      amount: 3000.0,
      quantity: 1,
    ),
    PaymentItem(
      itemNumber: "PART001",
      name: "Air Filter",
      amount: 2000.0,
      quantity: 2,
    ),
  ];

  CustomerInfo customer = CustomerInfo(
    firstName: "Jane",
    lastName: "Smith",
    email: "jane.smith@example.com",
    phone: "0771234567",
    address: "No. 456, Kandy Road",
    city: "Kandy",
  );

  double total = items.fold(0, (sum, item) => sum + (item.amount * item.quantity));

  PaymentService.makeItemizedPayment(
    orderId: "SRV-${DateTime.now().millisecondsSinceEpoch}",
    items: items,
    totalAmount: total,
    customerInfo: customer,
  );
}
```

## 🔔 Important Notes

### Backend Integration
To receive payment notifications and verify payments, you need to set up a backend endpoint:

1. Create an endpoint that accepts POST requests (set as `notify_url`)
2. PayHere will send payment notifications to this URL
3. Verify the payment details and update your database
4. Read PayHere documentation for notification format:
   - One-time payments: https://support.payhere.lk/api-&-mobile-sdk/payhere-checkout#2-one-time-payment-notification
   - Recurring payments: https://support.payhere.lk/api-&-mobile-sdk/payhere-checkout#3-recurring-payment-notification
   - Preapproval: https://support.payhere.lk/api-&-mobile-sdk/payhere-checkout#4-preapproval-notification

### Testing
1. Use `"sandbox": true` for testing
2. Use PayHere sandbox merchant credentials
3. Test with PayHere test card numbers (available in PayHere docs)
4. Switch to production credentials and set `"sandbox": false` for live deployment

### Security
- **Never** hardcode production merchant credentials in the app
- Store sensitive credentials in environment variables or secure backend
- Always verify payment status from your backend
- Implement proper error handling and logging

## 🎯 Platform Support
- ✅ Android: API Level 17+
- ✅ iOS: iOS 11.0+
- ✅ Flutter: 1.20.0+
- ✅ Null Safety: Supported (v3.2.0+)

## 📚 Additional Resources
- [PayHere Flutter SDK Documentation](https://pub.dev/packages/payhere_mobilesdk_flutter)
- [PayHere GitHub Repository](https://github.com/PayHereLK/payhere-mobilesdk-flutter)
- [PayHere API Documentation](https://support.payhere.lk/api-&-mobile-sdk)
- [PayHere Merchant Dashboard](https://www.payhere.lk/merchant)

## ✅ Integration Checklist
- [x] PayHere SDK added to pubspec.yaml
- [x] Flutter dependencies installed
- [x] Android Maven repository configured
- [x] AndroidManifest.xml updated
- [x] ProGuard rules added
- [ ] App package name whitelisted in PayHere dashboard
- [ ] Merchant credentials obtained
- [ ] Payment service implemented
- [ ] Backend notification endpoint created
- [ ] Testing completed in sandbox mode
- [ ] Production deployment configured
