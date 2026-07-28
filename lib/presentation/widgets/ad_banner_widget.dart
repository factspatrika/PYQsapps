import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/caching_service.dart';
import '../../data/repositories/purchase_service.dart';
import '../theme/app_theme.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // 1. Don't show ads if user is Premium
    if (PurchaseService.isPremiumUser) return;

    // 2. Check remote/local show_ads setting
    final settingsBox = Hive.box(CachingService.settingsBoxName);
    final bool showAds = settingsBox.get('show_ads', defaultValue: true) as bool;
    if (!showAds) return;

    // 3. Get dynamic AdMob Unit ID
    final String androidAdId = settingsBox.get(
      'admob_android_banner_id',
      defaultValue: 'ca-app-pub-3940256099942544/6300978111',
    ) as String;

    final String iosAdId = settingsBox.get(
      'admob_ios_banner_id',
      defaultValue: 'ca-app-pub-3940256099942544/2934735716',
    ) as String;

    // 4. Only load native ads on mobile
    if (kIsWeb) return;

    final String adUnitId = Platform.isAndroid ? androidAdId : iosAdId;

    if (Platform.isAndroid || Platform.isIOS) {
      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isLoaded = true;
              });
            }
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
    if (PurchaseService.isPremiumUser) {
      return const SizedBox.shrink();
    }

    final settingsBox = Hive.box(CachingService.settingsBoxName);
    final bool showAds = settingsBox.get('show_ads', defaultValue: true) as bool;
    if (!showAds) {
      return const SizedBox.shrink();
    }

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
