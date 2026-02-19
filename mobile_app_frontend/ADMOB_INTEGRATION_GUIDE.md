# AdMob Integration Guide

## ✅ What's Been Set Up

### 1. **Package Installed**
- `google_mobile_ads: ^5.2.0` added to pubspec.yaml

### 2. **Android Configuration**
- AdMob App ID added to AndroidManifest.xml
- Currently using **test App ID**: `ca-app-pub-3940256099942544~3347511713`

### 3. **Files Created**
- `lib/services/admob_service.dart` - AdMob service with helper methods
- `lib/widgets/banner_ad_widget.dart` - Reusable banner ad widget
- `lib/screens/admob_example_screen.dart` - Example screen showing all ad types

### 4. **AdMob Initialized**
- AdMob is initialized in `main.dart` before the app runs

---

## 🚀 How to Use Ads in Your App

### **Banner Ads** (Bottom of screen)

Add this to any screen:

```dart
import 'package:mobile_app_frontend/widgets/banner_ad_widget.dart';

// In your build method:
Column(
  children: [
    Expanded(
      child: YourContent(),
    ),
    BannerAdWidget(), // Add banner ad at bottom
  ],
)
```

### **Interstitial Ads** (Full-screen ads)

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile_app_frontend/services/admob_service.dart';

class YourScreen extends StatefulWidget {
  @override
  State<YourScreen> createState() => _YourScreenState();
}

class _YourScreenState extends State<YourScreen> {
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  Future<void> _loadInterstitialAd() async {
    _interstitialAd = await AdMobService.loadInterstitialAd();
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd(); // Load next ad
      },
    );
  }

  void _showAd() {
    _interstitialAd?.show();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
```

### **Rewarded Ads** (User earns rewards)

```dart
RewardedAd? _rewardedAd;

Future<void> _loadRewardedAd() async {
  _rewardedAd = await AdMobService.loadRewardedAd();
}

void _showRewardedAd() {
  _rewardedAd?.show(
    onUserEarnedReward: (ad, reward) {
      print('User earned: ${reward.amount} ${reward.type}');
      // Give user their reward here
    },
  );
}
```

---

## 📝 Next Steps - Get Your Real AdMob IDs

### **Step 1: Create AdMob Account**
1. Go to [AdMob Console](https://apps.admob.com/)
2. Sign in with your Google account
3. Create an account if you don't have one

### **Step 2: Create an App**
1. Click **Apps** > **Add App**
2. Choose **Android** platform
3. Enter your app name: "Vehicle Pass App" (or your app name)
4. Click **Add**

### **Step 3: Get Your App ID**
After creating the app, you'll get an **App ID** like:
```
ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
```

**Update it in** `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

### **Step 4: Create Ad Units**
1. In AdMob Console, go to **Ad units** > **Add ad unit**
2. Create these ad unit types:
   - **Banner** (for bottom ads)
   - **Interstitial** (for full-screen ads)
   - **Rewarded** (optional - for reward-based ads)

3. Copy each **Ad Unit ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`)

### **Step 5: Update Ad Unit IDs**
In `lib/services/admob_service.dart`, replace the test IDs:

```dart
static String get bannerAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ'; // Your Banner ID
  }
  // ...
}

static String get interstitialAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ'; // Your Interstitial ID
  }
  // ...
}
```

---

## ⚠️ Important Notes

### **Test Ads**
- Currently using **Google's test ad IDs**
- Test ads will show while developing
- **Must replace with real IDs before publishing**

### **Ad Display Rules**
- Don't show too many ads (users will hate it)
- Banner ads: 1 per screen max
- Interstitial ads: Show between natural breaks (e.g., after completing an action)
- Rewarded ads: Offer users something valuable

### **AdMob Policies**
- Never click your own ads
- Don't encourage users to click ads
- Follow [AdMob policies](https://support.google.com/admob/answer/6128543)

---

## 🧪 Testing

To test the example screen:
1. Add navigation to `AdMobExampleScreen` from your app
2. Or temporarily set it as home in `main.dart`:
   ```dart
   home: AdMobExampleScreen(),
   ```

---

## 💰 Where to Show Ads

### Recommended Placements:
- **Banner ads**: Bottom of main screens (Home, Dashboard, etc.)
- **Interstitial ads**: 
  - After completing a fuel log
  - After viewing service history
  - Between major navigation flows
- **Rewarded ads**:
  - Unlock premium features temporarily
  - Get extra loyalty points
  - Remove ads for a session

---

## 📞 Common Issues

### Ad not showing?
- Check internet connection
- Make sure AdMob is initialized
- Wait a few seconds for ad to load
- Check console for error messages

### "Ad failed to load"?
- Normal in development/testing
- Test ads have limited inventory
- Real ads will load better in production

---

**You're all set! The test ads should work immediately. Replace with real IDs when you're ready to publish.** 🎉
