// Example: How to use PaymentScreen in your app
// Navigate to payment screen from appointment booking

import 'package:flutter/material.dart';
import 'screens/payment_screen.dart';
import 'screens/itemized_payment_screen.dart';
import 'services/payment_service.dart';

// Example 1: Simple appointment payment
void navigateToSimplePayment(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentScreen(
        appointmentId: "12345",
        amount: 5000.0,
        serviceDescription: "Vehicle Oil Change Service",
      ),
    ),
  );
}

// Example 2: Itemized service payment
void navigateToItemizedPayment(BuildContext context) {
  // Create service items list
  List<ServiceItem> serviceItems = [
    ServiceItem(
      itemNumber: "SRV001",
      name: "Engine Oil Change",
      amount: 3000.0,
      quantity: 1,
      description: "Premium synthetic oil",
    ),
    ServiceItem(
      itemNumber: "SRV002",
      name: "Oil Filter",
      amount: 800.0,
      quantity: 1,
      description: "OEM quality filter",
    ),
    ServiceItem(
      itemNumber: "SRV003",
      name: "Brake Fluid Top-up",
      amount: 500.0,
      quantity: 1,
    ),
    ServiceItem(
      itemNumber: "LAB001",
      name: "Labor Charges",
      amount: 1500.0,
      quantity: 1,
    ),
  ];

  // Create customer info
  CustomerInfo customer = CustomerInfo(
    firstName: "John",
    lastName: "Doe",
    email: "john.doe@example.com",
    phone: "0771234567",
    address: "123 Main Street, Colombo",
    city: "Colombo",
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ItemizedPaymentScreen(
        serviceId: "SRV-67890",
        serviceItems: serviceItems,
        customerInfo: customer,
      ),
    ),
  );
}

// Example 3: Direct payment without screen (for quick payments)
void processQuickPayment(BuildContext context, CustomerInfo customer) async {
  await PaymentService.makeServicePayment(
    orderId: "QUICK-${DateTime.now().millisecondsSinceEpoch}",
    itemDescription: "Emergency Service Fee",
    amount: 1000.0,
    firstName: customer.firstName,
    lastName: customer.lastName,
    email: customer.email,
    phone: customer.phone,
    address: customer.address,
    city: customer.city,
    onSuccess: (paymentId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful! ID: $paymentId')),
      );
    },
    onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $error')),
      );
    },
    onDismissed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment cancelled')),
      );
    },
  );
}

// Example 4: Recurring subscription payment
void processRecurringPayment(
    BuildContext context, CustomerInfo customer) async {
  await PaymentService.makeRecurringPayment(
    orderId: "SUB-${DateTime.now().millisecondsSinceEpoch}",
    description: "Monthly Premium Membership",
    recurringAmount: 2500.0,
    recurrence: "1 Month",
    duration: "1 Year",
    startupFee: 1000.0, // One-time registration fee
    customerInfo: customer,
    onSuccess: (paymentId) {
      print("Subscription activated! Payment ID: $paymentId");
      // Save subscription to backend
    },
    onError: (error) {
      print("Subscription failed: $error");
    },
    onDismissed: () {
      print("Subscription cancelled by user");
    },
  );
}

// Example 5: Save card for future use (tokenization)
void saveCardForFutureUse(BuildContext context, CustomerInfo customer) async {
  await PaymentService.tokenizeCard(
    orderId: "TOKEN-${DateTime.now().millisecondsSinceEpoch}",
    customerInfo: customer,
    onSuccess: (paymentId) {
      print("Card saved successfully! Token ID: $paymentId");
      // Store the payment ID in your backend
      // Use PayHere Charging API to charge this card later
    },
    onError: (error) {
      print("Card tokenization failed: $error");
    },
    onDismissed: () {
      print("Card tokenization cancelled");
    },
  );
}

// Example 6: Hold amount on card (authorization)
void holdPaymentOnCard(BuildContext context, CustomerInfo customer) async {
  await PaymentService.authorizePayment(
    orderId: "AUTH-${DateTime.now().millisecondsSinceEpoch}",
    description: "Service Deposit Hold",
    amount: 5000.0,
    customerInfo: customer,
    onSuccess: (paymentId) {
      print("Payment authorized! Auth ID: $paymentId");
      // Save authorization ID in your backend
      // Use PayHere Capture API to capture the amount later
    },
    onError: (error) {
      print("Authorization failed: $error");
    },
    onDismissed: () {
      print("Authorization cancelled");
    },
  );
}

// Example 7: Button widget that triggers payment
class PayNowButton extends StatelessWidget {
  final double amount;
  final VoidCallback? onPaymentSuccess;

  const PayNowButton({
    Key? key,
    required this.amount,
    this.onPaymentSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              appointmentId: "12345",
              amount: amount,
              serviceDescription: "Vehicle Service",
            ),
          ),
        ).then((_) {
          // Called when returning from payment screen
          onPaymentSuccess?.call();
        });
      },
      icon: const Icon(Icons.payment),
      label: Text('Pay LKR ${amount.toStringAsFixed(2)}'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/* 
IMPORTANT SETUP STEPS BEFORE USING:

1. Update payment_service.dart with your credentials:
   - Replace merchantId with your PayHere Merchant ID
   - Replace merchantSecret with your Merchant Secret (from app whitelisting)
   - Update notifyUrl with your backend endpoint URL

2. Whitelist your app in PayHere dashboard:
   - Login to PayHere Merchant Account
   - Go to Settings > Domains & Credentials
   - Add app package: com.example.mobile_app_frontend
   - Note the Merchant Secret hash value

3. Setup backend notification endpoint:
   - Create POST endpoint to receive payment notifications
   - Verify payment status and update database
   - Return 200 OK response

4. For iOS build (on macOS):
   - Navigate to ios directory
   - Run: pod install

5. Testing:
   - Use sandbox mode (sandbox: true)
   - Use PayHere test card numbers
   - Test all payment scenarios

6. Production:
   - Change sandbox to false
   - Use production credentials
   - Test with real card in test mode first
*/
