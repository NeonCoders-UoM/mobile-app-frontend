# PayHere Payment Integration - Quick Start Guide

## ✅ What's Been Done

All PayHere SDK integration setup has been completed for your Flutter mobile app!

### Files Created/Modified:

1. **Android Configuration:**

   - ✅ `android/build.gradle` - PayHere Maven repository added
   - ✅ `android/app/build.gradle` - ProGuard configuration added
   - ✅ `android/app/proguard-rules.pro` - ProGuard rules created
   - ✅ `android/app/src/main/AndroidManifest.xml` - Already configured

2. **Flutter/Dart Files:**

   - ✅ `pubspec.yaml` - PayHere SDK dependency added
   - ✅ `lib/services/payment_service.dart` - Complete payment service
   - ✅ `lib/screens/payment_screen.dart` - Simple payment UI
   - ✅ `lib/screens/itemized_payment_screen.dart` - Itemized payment UI
   - ✅ `lib/examples/payment_usage_examples.dart` - Usage examples

3. **Documentation:**
   - ✅ `PAYHERE_INTEGRATION_COMPLETE.md` - Full integration guide
   - ✅ This quick start guide

## 🚀 Quick Start (3 Steps)

### Step 1: Get PayHere Credentials

1. Login to [PayHere Merchant Dashboard](https://www.payhere.lk/merchant)
2. Go to **Settings > Domains & Credentials**
3. Click **"Add Domain/App"**
4. Select **"App"** and enter: `com.example.mobile_app_frontend`
5. Copy the **Merchant Secret** hash value
6. Click **"Request to Approve"**

### Step 2: Update Configuration

Open `lib/services/payment_service.dart` and update:

```dart
static const String merchantId = "YOUR_MERCHANT_ID"; // e.g., "1211149"
static const String merchantSecret = "YOUR_MERCHANT_SECRET"; // From Step 1
static const bool sandboxMode = true; // Keep true for testing
static const String notifyUrl = "https://d2ba38d700ef.ngrok-free.app/api/payhere/notify";
```

### Step 3: Use in Your App

**Simple payment:**

```dart
import 'screens/payment_screen.dart';

// Navigate to payment
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaymentScreen(
      appointmentId: "12345",
      amount: 5000.0,
      serviceDescription: "Vehicle Service",
    ),
  ),
);
```

**Direct payment without UI:**

```dart
import 'services/payment_service.dart';

await PaymentService.makeServicePayment(
  orderId: "APT-12345",
  itemDescription: "Service Fee",
  amount: 5000.0,
  firstName: "John",
  lastName: "Doe",
  email: "john@example.com",
  phone: "0771234567",
  address: "123 Main St",
  city: "Colombo",
  onSuccess: (paymentId) => print("Success: $paymentId"),
  onError: (error) => print("Error: $error"),
  onDismissed: () => print("Cancelled"),
);
```

## 📱 Payment Types Available

### 1. One-Time Payment

For single service appointments or purchases.

```dart
PaymentService.makeServicePayment(...)
```

### 2. Itemized Payment

For multiple items/services in one payment.

```dart
PaymentService.makeItemizedPayment(...)
```

### 3. Recurring Payment

For subscriptions and monthly packages.

```dart
PaymentService.makeRecurringPayment(...)
```

### 4. Hold-on-Card

Authorize payment now, capture later.

```dart
PaymentService.authorizePayment(...)
```

### 5. Tokenization

Save card for future charging.

```dart
PaymentService.tokenizeCard(...)
```

## 🧪 Testing

### Test in Sandbox Mode:

1. Ensure `sandboxMode = true` in payment_service.dart
2. Use PayHere test merchant ID
3. Use PayHere test card numbers (see PayHere docs)
4. No real money will be charged

### PayHere Test Cards:

- See [PayHere Testing Guide](https://support.payhere.lk/api-&-mobile-sdk/test-payment)

## 🔒 Backend Setup (Important!)

You **must** create a backend endpoint to receive payment notifications:

```javascript
// Example Node.js endpoint
app.post("/payhere/notify", (req, res) => {
  const {
    merchant_id,
    order_id,
    payhere_amount,
    payhere_currency,
    status_code,
    md5sig,
    // ... other fields
  } = req.body;

  // 1. Verify the MD5 signature
  // 2. Check status_code (2 = success)
  // 3. Update your database
  // 4. Send confirmation email

  res.status(200).send("OK");
});
```

**Notification formats:**

- [One-time payments](https://support.payhere.lk/api-&-mobile-sdk/payhere-checkout#2-one-time-payment-notification)
- [Recurring payments](https://support.payhere.lk/api-&-mobile-sdk/payhere-checkout#3-recurring-payment-notification)
- [Preapproval](https://support.payhere.lk/api-&-mobile-sdk/payhere-checkout#4-preapproval-notification)

## 📋 Pre-Flight Checklist

- [ ] PayHere merchant account created
- [ ] App package name whitelisted in PayHere dashboard
- [ ] Merchant ID obtained
- [ ] Merchant Secret obtained
- [ ] Credentials updated in payment_service.dart
- [ ] Backend notification endpoint created
- [ ] Tested in sandbox mode
- [ ] Ready for production

## 🎯 Next Steps

1. **Test the integration:**

   ```bash
   flutter run -d YOUR_DEVICE
   ```

2. **Navigate to a payment screen** from your app

3. **Complete a test payment** using sandbox mode

4. **Verify backend receives notification**

5. **Switch to production:**
   - Set `sandboxMode = false`
   - Use production merchant credentials
   - Test with real card in small amounts first

## 📚 Resources

- [PayHere Flutter SDK](https://pub.dev/packages/payhere_mobilesdk_flutter)
- [PayHere Documentation](https://support.payhere.lk/api-&-mobile-sdk)
- [PayHere Dashboard](https://www.payhere.lk/merchant)
- Full guide: `PAYHERE_INTEGRATION_COMPLETE.md`
- Usage examples: `lib/examples/payment_usage_examples.dart`

## 💡 Usage Examples

Check `lib/examples/payment_usage_examples.dart` for:

- Simple appointment payment
- Itemized service payment
- Direct payment calls
- Recurring subscriptions
- Card tokenization
- Payment authorization
- Custom payment buttons

## ⚠️ Important Notes

1. **Never hardcode production credentials** in the app
2. **Always verify payments** from your backend
3. **Test thoroughly** in sandbox mode first
4. **Handle all callback scenarios** (success, error, dismissed)
5. **Store payment IDs** for future reference
6. **Implement proper error handling**

## 🆘 Need Help?

- Check `PAYHERE_INTEGRATION_COMPLETE.md` for detailed documentation
- Review `lib/examples/payment_usage_examples.dart` for code samples
- Visit [PayHere Support](https://support.payhere.lk/)
- Contact PayHere at support@payhere.lk

---

**You're all set!** 🎉 The PayHere integration is ready to use in your Flutter app.
