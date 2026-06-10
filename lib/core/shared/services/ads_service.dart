import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppAdPlacement { home, flashcard }

enum AppInterstitialPlacement { flashcard }

class AdsService {
  AdsService._();

  static final AdsService instance = AdsService._();

  static const bool _enableGoogleAdsDefine = bool.fromEnvironment(
    'ENABLE_GOOGLE_ADS',
    defaultValue: false,
  );

  static const String _androidHomeBannerDefine = String.fromEnvironment(
    'ADMOB_ANDROID_HOME_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );
  static const String _androidFlashcardBannerDefine = String.fromEnvironment(
    'ADMOB_ANDROID_FLASHCARD_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );
  static const String _iosHomeBannerDefine = String.fromEnvironment(
    'ADMOB_IOS_HOME_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );
  static const String _iosFlashcardBannerDefine = String.fromEnvironment(
    'ADMOB_IOS_FLASHCARD_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );

  static const String _androidFlashcardInterstitialDefine =
      String.fromEnvironment(
    'ADMOB_ANDROID_FLASHCARD_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );
  static const String _iosFlashcardInterstitialDefine = String.fromEnvironment(
    'ADMOB_IOS_FLASHCARD_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910',
  );

  bool _initialized = false;

  final Map<AppInterstitialPlacement, InterstitialAd?> _interstitialAds = {};
  final Map<AppInterstitialPlacement, bool> _interstitialLoading = {};

  bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get canShowAds => false; // _resolveAdsEnabled() && isSupportedPlatform;

  Future<void> initialize() async {
    if (!canShowAds || _initialized) return;

    await MobileAds.instance.initialize();

    final testDeviceIds = _readTestDeviceIds();
    if (testDeviceIds.isNotEmpty) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: testDeviceIds),
      );
    }

    _initialized = true;
  }

  List<String> _readTestDeviceIds() {
    final raw = dotenv.env['ADS_TEST_DEVICE_IDS'] ??
        const String.fromEnvironment(
          'ADS_TEST_DEVICE_IDS',
          defaultValue: '',
        );
    if (raw.trim().isEmpty) return const <String>[];

    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  bool _resolveAdsEnabled() {
    final raw = dotenv.env['ENABLE_GOOGLE_ADS'];
    if (raw == null || raw.trim().isEmpty) return _enableGoogleAdsDefine;

    final normalized = raw.trim().toLowerCase();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'y';
  }

  String _pickBannerId(String? dotenvValue, String defineValue) {
    final trimmed = (dotenvValue ?? '').trim();
    return trimmed.isNotEmpty ? trimmed : defineValue;
  }

  String _pickInterstitialId(String? dotenvValue, String defineValue) {
    final trimmed = (dotenvValue ?? '').trim();
    return trimmed.isNotEmpty ? trimmed : defineValue;
  }

  String? bannerUnitId(AppAdPlacement placement) {
    if (!canShowAds) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return switch (placement) {
          AppAdPlacement.home => _pickBannerId(
            dotenv.env['ADMOB_ANDROID_HOME_BANNER_ID'],
            _androidHomeBannerDefine,
          ),
          AppAdPlacement.flashcard => _pickBannerId(
            dotenv.env['ADMOB_ANDROID_FLASHCARD_BANNER_ID'],
            _androidFlashcardBannerDefine,
          ),
        };
      case TargetPlatform.iOS:
        return switch (placement) {
          AppAdPlacement.home => _pickBannerId(
            dotenv.env['ADMOB_IOS_HOME_BANNER_ID'],
            _iosHomeBannerDefine,
          ),
          AppAdPlacement.flashcard => _pickBannerId(
            dotenv.env['ADMOB_IOS_FLASHCARD_BANNER_ID'],
            _iosFlashcardBannerDefine,
          ),
        };
      default:
        return null;
    }
  }

  String? interstitialUnitId(AppInterstitialPlacement placement) {
    if (!canShowAds) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return switch (placement) {
          AppInterstitialPlacement.flashcard => _pickInterstitialId(
            dotenv.env['ADMOB_ANDROID_FLASHCARD_INTERSTITIAL_ID'],
            _androidFlashcardInterstitialDefine,
          ),
        };
      case TargetPlatform.iOS:
        return switch (placement) {
          AppInterstitialPlacement.flashcard => _pickInterstitialId(
            dotenv.env['ADMOB_IOS_FLASHCARD_INTERSTITIAL_ID'],
            _iosFlashcardInterstitialDefine,
          ),
        };
      default:
        return null;
    }
  }

  Future<void> preloadInterstitial(AppInterstitialPlacement placement) async {
    if (!canShowAds) return;
    if (_interstitialAds[placement] != null) return;
    if (_interstitialLoading[placement] == true) return;

    final unitId = interstitialUnitId(placement);
    if (unitId == null || unitId.trim().isEmpty) return;

    _interstitialLoading[placement] = true;
    await InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading[placement] = false;
          _interstitialAds[placement] = ad;
        },
        onAdFailedToLoad: (_) {
          _interstitialLoading[placement] = false;
          _interstitialAds[placement] = null;
        },
      ),
    );
  }

  Future<bool> showInterstitial(
    AppInterstitialPlacement placement, {
    VoidCallback? onDismissed,
    VoidCallback? onFailedToShow,
  }) async {
    if (!canShowAds) return false;

    final ad = _interstitialAds[placement];
    if (ad == null) {
      await preloadInterstitial(placement);
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAds[placement] = null;
        onDismissed?.call();
        preloadInterstitial(placement);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAds[placement] = null;
        onFailedToShow?.call();
        preloadInterstitial(placement);
      },
    );

    ad.show();
    return true;
  }
}
