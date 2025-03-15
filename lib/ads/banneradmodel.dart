import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner1 extends StatefulWidget {
  @override
  State<AdBanner1> createState() => _AdBanner1State();
}

class _AdBanner1State extends State<AdBanner1> {
  BannerAd? mybannerAd;
  bool isAdsReady = false;
  final AdSize adsize = AdSize.banner;
  void createmybannerAd() {
    mybannerAd = BannerAd(
        size: adsize,
        adUnitId: 'ca-app-pub-6088367933724448/968606256200',
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            isAdsReady = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          log('masad9ach lbanner : ${error.message}');
        }),
        request: const AdRequest());
    mybannerAd!.load();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createmybannerAd();
  }

  @override
  Widget build(BuildContext context) {
    if (isAdsReady) {
      return Container(
        width: adsize.width.toDouble(),
        height: adsize.height.toDouble(),
        child: AdWidget(ad: mybannerAd!),
        alignment: Alignment.center,
      );
    }
    return Container();
  }
}
