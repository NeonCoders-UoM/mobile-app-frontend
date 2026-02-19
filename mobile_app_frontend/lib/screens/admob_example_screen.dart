import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile_app_frontend/services/admob_service.dart';
import 'package:mobile_app_frontend/widgets/banner_ad_widget.dart';

/// Example screen showing how to use different types of ads
class AdMobExampleScreen extends StatefulWidget {
  const AdMobExampleScreen({Key? key}) : super(key: key);

  @override
  State<AdMobExampleScreen> createState() => _AdMobExampleScreenState();
}

class _AdMobExampleScreenState extends State<AdMobExampleScreen> {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  /// Load Interstitial Ad
  Future<void> _loadInterstitialAd() async {
    _interstitialAd = await AdMobService.loadInterstitialAd();
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd(); // Load next ad
      },
    );
  }

  /// Show Interstitial Ad
  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd?.show();
    } else {
      print('❌ Interstitial ad is not ready yet');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad not ready yet')),
      );
    }
  }

  /// Load Rewarded Ad
  Future<void> _loadRewardedAd() async {
    _rewardedAd = await AdMobService.loadRewardedAd();
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd(); // Load next ad
      },
    );
  }

  /// Show Rewarded Ad
  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          print('✅ User earned reward: ${reward.amount} ${reward.type}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You earned ${reward.amount} ${reward.type}!'),
            ),
          );
        },
      );
    } else {
      print('❌ Rewarded ad is not ready yet');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad not ready yet')),
      );
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob Example'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'AdMob Integration Example',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  
                  // Interstitial Ad Button
                  ElevatedButton.icon(
                    onPressed: _showInterstitialAd,
                    icon: const Icon(Icons.fullscreen),
                    label: const Text('Show Interstitial Ad'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Rewarded Ad Button
                  ElevatedButton.icon(
                    onPressed: _showRewardedAd,
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('Show Rewarded Ad'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.green,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Banner ad is displayed at the bottom of the screen',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Banner Ad at the bottom
          const BannerAdWidget(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
