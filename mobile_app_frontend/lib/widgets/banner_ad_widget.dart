import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile_app_frontend/services/admob_service.dart';

/// Reusable Banner Ad Widget
/// Can be placed at the bottom of any screen
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;

  const BannerAdWidget({
    Key? key,
    this.adSize = AdSize.banner,
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdMobService.createBannerAd(
      adSize: widget.adSize,
      onAdLoaded: (ad) {
        setState(() {
          _isAdLoaded = true;
        });
        print('✅ Banner ad loaded');
      },
      onAdFailedToLoad: (ad, error) {
        print('❌ Banner ad failed to load: $error');
        ad.dispose();
      },
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return SizedBox(height: widget.adSize.height.toDouble());
    }

    return Container(
      alignment: Alignment.center,
      width: widget.adSize.width.toDouble(),
      height: widget.adSize.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
