import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme/app_theme.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  late final String _adUnitId = kIsWeb
      ? ''
      : (Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android test ID
          : 'ca-app-pub-3940256099942544/2934735716'); // iOS test ID

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Only load native ads on mobile
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _bannerAd = BannerAd(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _isLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
          },
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show a placeholder on Web or when testing on Desktop
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return Container(
        height: 50,
        width: 320,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FF),
          border: Border.all(color: const Color(0xFFC4C6CC), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'ADVERTISEMENT',
            style: TextStyle(
              color: AppTheme.subtitleColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      );
    }

    // Show native AdMob banner if loaded
    if (_isLoaded && _bannerAd != null) {
      return Container(
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    return const SizedBox.shrink(); // Hide if not loaded
  }
}
