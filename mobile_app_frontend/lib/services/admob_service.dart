import 'dart:io';import 'dart:async';import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  /// Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    print('✅ AdMob initialized');
  }

  /// Get Banner Ad Unit ID
  /// Returns test ad ID for now - replace with your actual ad IDs from AdMob
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Test Ad Unit ID for Android
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // Test Ad Unit ID for iOS
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get Rewarded Ad Unit ID
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Create a Banner Ad
  static BannerAd createBannerAd({
    required AdSize adSize,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    required Function(Ad ad) onAdLoaded,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
      ),
    );
  }

  /// Load an Interstitial Ad with retry logic
  static Future<InterstitialAd?> loadInterstitialAd({int maxRetries = 3}) async {
    for (int retryCount = 0; retryCount < maxRetries; retryCount++) {
      final Completer<InterstitialAd?> completer = Completer<InterstitialAd?>();
      
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            print('✅ Interstitial ad loaded');
            if (!completer.isCompleted) {
              completer.complete(ad);
            }
          },
          onAdFailedToLoad: (error) {
            print('❌ Interstitial ad failed to load (attempt ${retryCount + 1}/$maxRetries): $error');
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
        ),
      );

      // Wait for the ad to load or fail
      final InterstitialAd? result = await completer.future;
      
      if (result != null) {
        return result; // Successfully loaded
      }

      // Wait before retrying (exponential backoff)
      if (retryCount < maxRetries - 1) {
        final waitTime = (retryCount + 1) * 2;
        print('🔄 Retrying in $waitTime seconds...');
        await Future.delayed(Duration(seconds: waitTime));
      }
    }

    print('⚠️ Failed to load interstitial ad after $maxRetries attempts');
    return null;
  }

  /// Load a Rewarded Ad
  static Future<RewardedAd?> loadRewardedAd() async {
    final Completer<RewardedAd?> completer = Completer<RewardedAd?>();

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Rewarded ad loaded');
          if (!completer.isCompleted) {
            completer.complete(ad);
          }
        },
        onAdFailedToLoad: (error) {
          print('❌ Rewarded ad failed to load: $error');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      ),
    );

    return completer.future;
  }
}
