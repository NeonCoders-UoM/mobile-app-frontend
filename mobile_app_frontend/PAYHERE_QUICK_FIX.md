# 🚨 IMMEDIATE ACTION REQUIRED - FIX PAYHERE ERROR

## The Problem

Your app shows: **"Init Payment method call failed"**

## The Cause

❌ **Merchant secret is a placeholder:** `"YOUR_ACTUAL_MERCHANT_SECRET_HERE"`
❌ **Wrong notify_url:** Was pointing to PayHere instead of your backend

## ✅ THE FIX (2 Simple Steps)

### Step 1: Get Your Merchant Secret (2 minutes)

1. Go to: **https://sandbox.payhere.lk/**
2. Login with your merchant account
3. Click: **Settings** → **Domains & Credentials**
4. Find or add app: `com.example.mobile_app_frontend`
5. **COPY the hash/secret value** (looks like: `MjA3MDQxMjIzNDE5MTc5...`)

### Step 2: Update Your Code (30 seconds)

**File:** `lib/presentation/pages/payhere_payment_page.dart`

**Find this line (~54):**

```dart
"merchant_secret": "YOUR_ACTUAL_MERCHANT_SECRET_HERE",
```

**Replace with YOUR secret:**

```dart
"merchant_secret": "paste_your_copied_secret_here",
```

### Step 3: Test Again

```bash
flutter run -d XNSNW19B26000520
```

---

## 🧪 Test Payment Details

Once you update the merchant secret, use these to test:

**Sandbox Test Card:**

- Card Number: `4916 2172 1144 8659`
- Expiry: `12/25` (any future date)
- CVV: `123` (any 3 digits)
- Name: Any name

---

## ✅ What Was Fixed

### 1. Merchant Secret

```diff
- "merchant_secret": "MzQxNjgzNzU1NTE2ODA1..." (wrong/base64)
+ "merchant_secret": "YOUR_ACTUAL_SECRET_HERE" (need to update)
```

### 2. Notify URL

```diff
- "notify_url": "https://sandbox.payhere.lk/notify" (wrong!)
+ "notify_url": "http://192.168.8.161:5039/api/payhere/notify" (correct)
```

### 3. Added Debug Logging

The app now prints payment details before sending to PayHere.

### 4. Added Validation

App will warn you if merchant secret is not updated.

---

## 📊 Expected Output After Fix

**In console, you should see:**

```
🔍 ========== PAYHERE PAYMENT DEBUG ==========
🔍 Merchant ID: 1230582
🔍 Merchant Secret: MjA3MDQxMj...
🔍 Notify URL: http://192.168.8.161:5039/api/payhere/notify
🔍 Order ID: vehicle_123_1701389847123
🔍 Amount: 500.00 LKR
🔍 Customer: John Doe
🔍 Email: john@example.com
🔍 ==========================================
🚀 Initiating PayHere payment...
```

**Then PayHere UI will open with payment methods displayed.**

---

## 🆘 Still Having Issues?

See full troubleshooting guide: `PAYHERE_INIT_ERROR_FIX.md`

### Quick Checks:

- [ ] Merchant secret updated (not placeholder)
- [ ] App package whitelisted in PayHere dashboard
- [ ] Backend is running on `http://192.168.8.161:5039`
- [ ] Device can reach backend URL

---

**UPDATE THE MERCHANT SECRET NOW AND TEST AGAIN! 🚀**
