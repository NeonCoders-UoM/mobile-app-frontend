# PayHere "Init Payment method call failed" - TROUBLESHOOTING GUIDE

## 🔴 Error Detected

```
D/PaymentMethodFragment( 3868): Init Payment method call failed
```

## ✅ FIXES APPLIED

### 1. Fixed notify_url

**Problem:** You were using PayHere's own URL instead of your backend

```dart
// ❌ WRONG
"notify_url": "https://sandbox.payhere.lk/notify"

// ✅ CORRECT
"notify_url": "http://192.168.8.161:5039/api/payhere/notify"
```

### 2. Fixed Merchant Secret Format

**Problem:** Merchant secret appeared to be base64 encoded

```dart
// ❌ WRONG (base64 encoded)
"merchant_secret": "MzQxNjgzNzU1NTE2ODA1MjMzMzM0MjkwNzU3OTIyMjMxMTY0NjcyNQ=="

// ✅ CORRECT (raw secret from PayHere dashboard)
"merchant_secret": "YOUR_ACTUAL_MERCHANT_SECRET_HERE"
```

### 3. Cleaned Up Payment Object

Removed unnecessary fields and improved name splitting.

## 🚨 ACTION REQUIRED - DO THIS NOW!

### Step 1: Get Your ACTUAL Merchant Secret

1. **Login to PayHere Sandbox:**

   - Go to: https://sandbox.payhere.lk/
   - Login with your merchant account

2. **Navigate to Settings:**

   - Click on **Settings** > **Domains & Credentials**

3. **Find/Add Your App:**

   - Look for your app package: `com.example.mobile_app_frontend`
   - If not found, click **"Add Domain/App"**
   - Select **"App"**
   - Enter: `com.example.mobile_app_frontend`
   - Click **"Request to Approve"**

4. **Get the Merchant Secret:**
   - You'll see a **hash value** - THIS is your merchant secret
   - Copy this EXACT value (it will be a long alphanumeric string)
   - Example format: `MjA3MDQxMjIzNDE5MTc5MzUxOTI2MDA5MjIyMjM3OTMyNTE0NzEwNw==`

### Step 2: Update Your Code

Open: `lib/presentation/pages/payhere_payment_page.dart`

Find line ~50 and replace:

```dart
"merchant_secret": "YOUR_ACTUAL_MERCHANT_SECRET_HERE",
```

With your actual secret:

```dart
"merchant_secret": "your_copied_merchant_secret_from_payhere_dashboard",
```

### Step 3: Verify Your Backend Endpoint

Make sure this endpoint exists and is running:

```
http://192.168.8.161:5039/api/payhere/notify
```

**Backend should handle:**

```javascript
// Example Node.js/Express
app.post("/api/payhere/notify", (req, res) => {
  console.log("Payment notification received:", req.body);

  const {
    merchant_id,
    order_id,
    payhere_amount,
    payhere_currency,
    status_code, // 2 = success, 0 = pending, -1 = cancelled, -2 = failed
    md5sig,
  } = req.body;

  // 1. Verify MD5 signature (important for security!)
  // 2. Update your database based on status_code
  // 3. Send confirmation email if needed

  res.status(200).send("OK");
});
```

## 🧪 TESTING STEPS

### Test 1: Verify Credentials

```dart
// Add these debug prints in your payment page before PayHere.startPayment()
print('🔍 Merchant ID: ${paymentObject["merchant_id"]}');
print('🔍 Merchant Secret: ${paymentObject["merchant_secret"]?.substring(0, 10)}...');
print('🔍 Notify URL: ${paymentObject["notify_url"]}');
print('🔍 Amount: ${paymentObject["amount"]}');
```

### Test 2: Check Network

Make sure your device can reach your backend:

```bash
# From your device's browser, try:
http://192.168.8.161:5039/api/payhere/status
```

### Test 3: Validate Payment Object

Add validation before calling PayHere:

```dart
// Add this before PayHere.startPayment()
if (paymentObject["merchant_secret"] == "YOUR_ACTUAL_MERCHANT_SECRET_HERE") {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('⚠️ Please update merchant secret!'),
      backgroundColor: Colors.red,
    ),
  );
  return;
}
```

## 📋 COMMON CAUSES CHECKLIST

- [ ] **Merchant Secret not updated** (still has placeholder)
- [ ] **notify_url points to wrong location** (must be YOUR backend)
- [ ] **App not whitelisted** in PayHere dashboard
- [ ] **Merchant ID is wrong** or doesn't match secret
- [ ] **Network connectivity issues** (device can't reach PayHere servers)
- [ ] **Amount is invalid** (must be > 0 and formatted as string with 2 decimals)
- [ ] **Backend endpoint doesn't exist** or returns error
- [ ] **Using production credentials in sandbox mode** (or vice versa)

## 🔍 DEBUGGING COMMANDS

### View Full Logs

```bash
# Run this in terminal to see detailed PayHere logs
flutter run -d XNSNW19B26000520 -v
```

### Check Network Traffic

Add this to your payment page to log the full payment object:

```dart
import 'dart:convert';

void _startPayment() async {
  // ... existing code ...

  print('📦 Full payment object:');
  print(jsonEncode(paymentObject));

  // Then call PayHere.startPayment()
}
```

## ✅ EXPECTED BEHAVIOR AFTER FIX

When you fix the merchant secret and notify_url, you should see:

1. **PayHere payment sheet opens** (UI loads properly)
2. **Payment methods are displayed** (cards, mobile banking, etc.)
3. **No "Init Payment method call failed"** error
4. **Test payment succeeds** with sandbox card

### Test Card Numbers (Sandbox)

Use these for testing:

- **Card Number:** 4916 2172 1144 8659
- **Expiry:** Any future date (e.g., 12/25)
- **CVV:** Any 3 digits (e.g., 123)
- **Name:** Any name

## 🆘 STILL NOT WORKING?

If you still get "Init Payment method call failed" after updating merchant secret:

1. **Double-check your merchant secret:**

   - Copy it again from PayHere dashboard
   - Make sure no extra spaces or characters
   - Verify it matches your merchant ID

2. **Verify app package name:**

   - Check AndroidManifest.xml: `com.example.mobile_app_frontend`
   - This MUST match what's whitelisted in PayHere

3. **Try with minimal payment object:**

   ```dart
   final paymentObject = {
     "sandbox": true,
     "merchant_id": "1230582",
     "merchant_secret": "your_actual_secret",
     "notify_url": "http://192.168.8.161:5039/api/payhere/notify",
     "order_id": "TEST_${DateTime.now().millisecondsSinceEpoch}",
     "items": "Test Payment",
     "amount": "100.00",
     "currency": "LKR",
     "first_name": "John",
     "last_name": "Doe",
     "email": "john@example.com",
     "phone": "0771234567",
     "address": "Colombo",
     "city": "Colombo",
     "country": "Sri Lanka",
   };
   ```

4. **Contact PayHere Support:**
   - Email: support@payhere.lk
   - Provide: Merchant ID, error logs, app package name

## 📝 QUICK FIX SUMMARY

1. ✅ Update `merchant_secret` with actual value from PayHere dashboard
2. ✅ Ensure `notify_url` points to YOUR backend (not PayHere's URL)
3. ✅ Verify app package name is whitelisted
4. ✅ Test with PayHere sandbox card numbers

---

**After you update the merchant secret, run the app again and the error should be resolved!**
