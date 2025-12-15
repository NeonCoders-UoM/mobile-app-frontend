# 🚨 FIX: "Unauthorized domain" PayHere Error

## ❌ The Error

```
Payment failed: Unauthorized domain
```

## 🔍 Root Cause

Your app package (`com.example.mobile_app_frontend`) is **NOT whitelisted** in PayHere merchant account.

---

## ✅ THE FIX - Follow These Steps

### Step 1: Whitelist Your App (REQUIRED)

1. **Login to PayHere Sandbox**

   - URL: https://sandbox.payhere.lk/
   - Use your merchant credentials

2. **Go to Settings → Domains & Credentials**

   - Click "Add Domain/App" button
   - Select **"App"** (NOT "Domain")
   - Enter: `com.example.mobile_app_frontend`
   - Click "Request to Approve"

3. **Verify Merchant Secret**
   - After adding, you'll see a **hash value**
   - This should match: `MTA4NzE3ODU2ODQwNTA4MTE1OTQzOTQxMDE0MzcyMjAyNTg2MDgy`
   - If different, copy the new value and update your code

### Step 2: Wait for Approval (If Required)

- **Sandbox:** Usually instant approval
- **Production:** May take up to 1 business day

### Step 3: Test Again

Run your app:

```bash
flutter run
```

---

## 🔧 What Was Fixed in Your Code

### Updated Files:

1. **`lib/services/payment_service.dart`**

   - ✅ Updated `notifyUrl` to your ngrok URL
   - ✅ Merchant secret verified

2. **`lib/presentation/pages/payhere_payment_page.dart`**

   - ✅ Updated merchant secret
   - ✅ Updated notify URL to ngrok

3. **`lib/presentation/pages/appointment_advance_payment_page.dart`**
   - ✅ Updated notify URL to ngrok
   - ✅ Removed hash field (not needed for mobile SDK)
   - ✅ Added debug logging

---

## 🧪 Debug Output

After the fix, you should see in console:

```
🔍 ========== APPOINTMENT PAYMENT DEBUG ==========
🔍 Merchant ID: 1230582
🔍 Merchant Secret: MTA4NzE3ODU...
🔍 Notify URL: https://43179df08648.ngrok-free.app/api/payhere/notify
🔍 Order ID: appointment_123_456_1701389847
🔍 Amount: 2500.00 LKR
🔍 ==========================================
🚀 Starting PayHere payment for appointment...
```

If whitelisted correctly:

```
✅ Appointment payment successful! Payment ID: XXXXXXXX
```

If still not whitelisted:

```
❌ Appointment payment failed: Unauthorized domain
```

---

## 📋 Checklist

Before testing, verify:

- [ ] App added in PayHere dashboard (Settings → Domains & Credentials)
- [ ] Package name is exactly: `com.example.mobile_app_frontend`
- [ ] Merchant secret matches: `MTA4NzE3ODU2ODQwNTA4MTE1OTQzOTQxMDE0MzcyMjAyNTg2MDgy`
- [ ] Notify URL is: `https://43179df08648.ngrok-free.app/api/payhere/notify`
- [ ] ngrok tunnel is running and accessible

---

## 🔍 How to Verify App Package Name

Check your `AndroidManifest.xml`:

```bash
# File: android/app/src/main/AndroidManifest.xml
```

Should show:

```xml
<manifest xmlns:android="..."
    package="com.example.mobile_app_frontend">
```

This **MUST** match exactly what you add in PayHere dashboard.

---

## 🆘 Still Getting Error?

### Common Issues:

1. **Wrong merchant secret**

   - Copy the EXACT value from PayHere dashboard
   - It's case-sensitive and character-specific

2. **App not approved yet**

   - Check PayHere dashboard status
   - Wait a few minutes for sandbox approval

3. **Wrong package name**

   - Verify in AndroidManifest.xml
   - Must match PayHere exactly

4. **Using production credentials in sandbox**
   - Make sure using sandbox merchant account
   - Sandbox URL: https://sandbox.payhere.lk/

### Debug Steps:

1. **Check console logs** after clicking "Proceed to Payment"
2. **Look for debug output** showing payment object
3. **Verify merchant secret** is not placeholder
4. **Test with simple PayHere test card** after whitelisting

---

## 📞 PayHere Support

If issue persists after whitelisting:

- Email: support@payhere.lk
- Provide: Merchant ID, App Package Name, Error Message

---

## ✅ Expected Flow After Fix

1. User clicks "Proceed to Payment"
2. Debug logs show payment details
3. PayHere SDK opens payment UI
4. User enters test card details
5. Payment succeeds
6. App navigates to success page

**The key is whitelisting your app in PayHere dashboard!**
