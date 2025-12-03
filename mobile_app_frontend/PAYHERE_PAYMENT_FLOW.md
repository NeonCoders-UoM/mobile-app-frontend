# PayHere Payment Flow Diagram

## Complete Payment Integration Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PAYHERE PAYMENT FLOW                          │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────┐
│   User App   │
│   (Flutter)  │
└──────┬───────┘
       │
       │ 1. User initiates payment
       │
       ▼
┌─────────────────────────────┐
│   Payment Screen/Service    │
│  (payment_screen.dart or    │
│   payment_service.dart)     │
└──────────┬──────────────────┘
           │
           │ 2. Collect customer info
           │    & payment details
           │
           ▼
┌──────────────────────────────┐
│   PaymentService.startPayment│
│   - Creates payment object   │
│   - Validates data           │
└──────────┬───────────────────┘
           │
           │ 3. Call PayHere SDK
           │
           ▼
┌──────────────────────────────┐
│     PayHere Mobile SDK       │
│  (payhere_mobilesdk_flutter) │
│   - Opens payment UI         │
│   - Handles card entry       │
│   - Processes payment        │
└──────────┬───────────────────┘
           │
           │ 4. User enters card details
           │    & confirms payment
           │
           ▼
┌──────────────────────────────┐
│   PayHere Payment Gateway    │
│   - Validates card           │
│   - Processes transaction    │
│   - Returns payment status   │
└──────────┬───────────────────┘
           │
           ├────────────────────────────────────┐
           │                                    │
           │ 5a. Success callback               │ 5b. Async notification
           │     (returns to app)               │     (to your backend)
           │                                    │
           ▼                                    ▼
┌──────────────────────────┐        ┌──────────────────────────┐
│   onSuccess callback     │        │   Backend Endpoint       │
│   - Receives paymentId   │        │   (notify_url)           │
│   - Shows success UI     │        │   - Receives POST        │
│   - Update local state   │        │   - Verifies signature   │
└──────────┬───────────────┘        │   - Updates database     │
           │                        │   - Sends confirmation   │
           │                        └──────────┬───────────────┘
           │                                   │
           │ 6. Navigate to success screen     │
           │    or update UI                   │
           │                                   │
           ▼                                   ▼
┌──────────────────────────┐        ┌──────────────────────────┐
│   Success Screen         │        │   Database Updated       │
│   - Show payment ID      │        │   - Order marked paid    │
│   - Confirmation message │        │   - Service activated    │
│   - Next actions         │        │   - Email sent           │
└──────────────────────────┘        └──────────────────────────┘
```

## Payment Types Flow

### 1. One-Time Payment

```
User → Payment Form → PayHere SDK → Payment → Success/Error
                                      ↓
                               Backend Notification
```

### 2. Itemized Payment

```
User → Service Items List → Calculate Total → PayHere SDK → Payment
              ↓
     Item 1: Oil Change
     Item 2: Brake Service
     Item 3: Labor
              ↓
         Total Amount
```

### 3. Recurring Payment

```
User → Subscription Form → Set Recurrence → PayHere SDK
                              ↓
                    Monthly/Weekly/Yearly
                              ↓
                      First Payment + Setup Fee
                              ↓
               Automatic recurring charges
```

### 4. Hold-on-Card (Authorization)

```
User → Authorization → PayHere SDK → Card Hold → Success
                                         ↓
                               Save Authorization ID
                                         ↓
                            Later: Backend Capture API
```

### 5. Tokenization (Save Card)

```
User → Save Card → PayHere SDK → Card Tokenized → Token ID
                                        ↓
                              Save Token in Backend
                                        ↓
                       Later: Charge API with Token
```

## Integration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     YOUR FLUTTER APP                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐     ┌─────────────────────┐          │
│  │  Payment Screens │────▶│  Payment Service    │          │
│  │  - Simple        │     │  - One-time         │          │
│  │  - Itemized      │     │  - Recurring        │          │
│  │  - Custom        │     │  - Authorization    │          │
│  └──────────────────┘     │  - Tokenization     │          │
│                           └──────────┬──────────┘          │
│                                      │                      │
│                                      ▼                      │
│                           ┌─────────────────────┐          │
│                           │  PayHere SDK        │          │
│                           │  (Package)          │          │
│                           └──────────┬──────────┘          │
└─────────────────────────────────────┼────────────────────────┘
                                      │
                                      ▼
                        ┌──────────────────────────┐
                        │  PayHere Gateway         │
                        │  (External Service)      │
                        └────────┬─────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
        ┌──────────────────┐    ┌──────────────────┐
        │  Mobile App      │    │  Your Backend    │
        │  (Callback)      │    │  (Notification)  │
        └──────────────────┘    └──────────────────┘
```

## File Structure

```
mobile_app_frontend/
├── lib/
│   ├── services/
│   │   └── payment_service.dart          ← Payment logic
│   │
│   ├── screens/
│   │   ├── payment_screen.dart           ← Simple payment UI
│   │   └── itemized_payment_screen.dart  ← Itemized payment UI
│   │
│   └── examples/
│       └── payment_usage_examples.dart   ← Usage examples
│
├── android/
│   ├── build.gradle                      ← Maven repository
│   └── app/
│       ├── build.gradle                  ← ProGuard config
│       └── proguard-rules.pro            ← ProGuard rules
│
├── pubspec.yaml                          ← PayHere dependency
│
└── Documentation:
    ├── PAYHERE_INTEGRATION_COMPLETE.md   ← Full guide
    ├── PAYHERE_QUICK_START.md            ← Quick start
    └── PAYHERE_PAYMENT_FLOW.md           ← This file
```

## Error Handling Flow

```
Payment Initiated
      │
      ├──▶ Network Error ──▶ onError("Network error") ──▶ Show retry
      │
      ├──▶ Card Declined ──▶ onError("Card declined") ──▶ Ask different card
      │
      ├──▶ User Cancelled ──▶ onDismissed() ──▶ Return to previous screen
      │
      └──▶ Success ──▶ onSuccess(paymentId) ──▶ Show confirmation
```

## Security Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      SECURITY MEASURES                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. SSL/TLS encryption for all communications               │
│     ├─ App ←→ PayHere Gateway                              │
│     └─ PayHere Gateway ←→ Backend                          │
│                                                              │
│  2. Merchant Secret verification                            │
│     ├─ Unique per app package                              │
│     └─ Required for all transactions                       │
│                                                              │
│  3. MD5 signature verification (Backend)                    │
│     ├─ Verify notification authenticity                    │
│     └─ Prevent tampering                                   │
│                                                              │
│  4. ProGuard obfuscation (Release builds)                   │
│     ├─ Protect app code                                    │
│     └─ Secure PayHere SDK                                  │
│                                                              │
│  5. PCI-DSS compliant                                       │
│     ├─ No card data stored in app                         │
│     └─ Handled by PayHere                                  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Testing Flow

```
Development Phase:
├─ Use sandbox mode (sandbox: true)
├─ Use test merchant credentials
├─ Use PayHere test cards
├─ Test all payment scenarios
└─ Verify backend notifications

Staging Phase:
├─ Use sandbox mode with production-like setup
├─ Test error scenarios
├─ Load testing
└─ Integration testing

Production Phase:
├─ Switch to production (sandbox: false)
├─ Use production credentials
├─ Test with small real amounts
├─ Monitor transactions
└─ Setup alerts for failures
```

## Backend Notification Processing

```
PayHere Payment Gateway
          │
          │ POST request with payment details
          │
          ▼
Your Backend Endpoint (notify_url)
          │
          ├─ 1. Receive POST data
          │     ├─ merchant_id
          │     ├─ order_id
          │     ├─ payhere_amount
          │     ├─ status_code
          │     ├─ md5sig
          │     └─ ... other fields
          │
          ├─ 2. Verify MD5 signature
          │     └─ Hash (merchant_id + order_id + amount + currency + status_code + md5_secret)
          │
          ├─ 3. Check status_code
          │     ├─ 2 = Success
          │     ├─ 0 = Pending
          │     ├─ -1 = Cancelled
          │     └─ -2 = Failed
          │
          ├─ 4. Update database
          │     ├─ Mark order as paid
          │     ├─ Update payment status
          │     └─ Store transaction details
          │
          ├─ 5. Send confirmations
          │     ├─ Email to customer
          │     ├─ SMS notification
          │     └─ Update app via push notification
          │
          └─ 6. Return 200 OK to PayHere
```

---

## Quick Reference

### Payment Methods

- ✅ Credit/Debit Cards (Visa, Mastercard, Amex)
- ✅ Mobile Banking (Sri Lankan banks)
- ✅ Digital Wallets

### Currencies Supported

- LKR (Sri Lankan Rupee)
- USD (US Dollar)
- GBP, EUR, AUD (and more)

### Supported Platforms

- ✅ Android (API 17+)
- ✅ iOS (11.0+)
- ✅ Flutter (1.20.0+)

### Transaction Limits

- Check with PayHere for merchant-specific limits
- Default: LKR 1.00 to LKR 1,000,000 per transaction

---

For implementation details, see:

- `PAYHERE_QUICK_START.md` - Get started quickly
- `PAYHERE_INTEGRATION_COMPLETE.md` - Complete documentation
- `lib/examples/payment_usage_examples.dart` - Code examples
