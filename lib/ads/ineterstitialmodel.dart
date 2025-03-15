import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdInterstitial1 {
  static InterstitialAd? interstitialAd;
  static bool isAdReady = false;

  static void loadInterstialAd() {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-6088367933724448/741512244000",
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              isAdReady = true;
              interstitialAd = ad;
            },
            onAdFailedToLoad: (error) {}));
  }

  static void showInterstitialAd() {
    if (isAdReady) {
      interstitialAd!.show();
    }
  }
}
