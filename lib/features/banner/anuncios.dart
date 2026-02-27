import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/ads_ids.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _banner;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdaptiveBanner();
  }

  Future<void> _loadAdaptiveBanner() async {
    final width = MediaQuery.of(context).size.width.toInt();

    final AdSize? adaptiveSize =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (adaptiveSize == null) return;

    _banner = BannerAd(
      size: adaptiveSize,
      adUnitId: AdsIds.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() {
            _isLoaded = true;
          });
          debugPrint('BANNER ADAPTATIVO CARREGOU');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('ERRO ANUNCIO: $error');
          ad.dispose();
        },
      ),
    );

    await _banner!.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _banner == null) {
      return const SizedBox(
        height: 60,
        child: Center(child: Text('Carregando anúncio...')),
      );
    }

    return SizedBox(
      width: _banner!.size.width.toDouble(),
      height: _banner!.size.height.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }
}