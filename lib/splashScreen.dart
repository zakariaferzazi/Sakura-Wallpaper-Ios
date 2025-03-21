import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'homepage.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  final int _splashDuration = 5; // Duration of the splash screen in seconds
  AppOpenAd? myAppOpenAd;

  loadAppOpenAd() {
    AppOpenAd.load(
        adUnitId: "ca-app-pub-6088367933724448/211469430600",
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
            onAdLoaded: (ad) {
              myAppOpenAd = ad;
              myAppOpenAd!.show();
            },
            onAdFailedToLoad: (error) {}),
        orientation: AppOpenAd.orientationPortrait);
  }

  @override
  void initState() {
    super.initState();

    loadAppOpenAd();
    Future.delayed(Duration(seconds: _splashDuration), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(15), // Adjust the radius as needed
              child: Image.asset(
                'assets/icon.png',
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            // Optional: App name
            const Text(
              'Sakura Wallpaper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}





























// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';

// import 'homepage.dart';

// class SplashScreenPage extends StatefulWidget {
//   const SplashScreenPage({Key? key}) : super(key: key);

//   @override
//   _SplashScreenPageState createState() => _SplashScreenPageState();
// }

// class _SplashScreenPageState extends State<SplashScreenPage> {
//   final int _splashDuration = 5; // Duration of the splash screen in seconds
//   late VideoPlayerController _videoPlayerController;
//   late ChewieController _chewieController;
//   AppOpenAd? myAppOpenAd;

//   loadAppOpenAd() {
//     AppOpenAd.load(
//         adUnitId: "ca-app-pub-6088367933724448/211469430622",
//         request: const AdRequest(),
//         adLoadCallback: AppOpenAdLoadCallback(
//             onAdLoaded: (ad) {
//               myAppOpenAd = ad;
//               myAppOpenAd!.show();
//             },
//             onAdFailedToLoad: (error) {}),
//         orientation: AppOpenAd.orientationPortrait);
//   }

//   @override
//   initState() {
//     super.initState();

//     loadAppOpenAd();
//     _initializeVideoPlayer();
//     Future.delayed(Duration(seconds: _splashDuration), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MyHomePage()),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _chewieController.dispose();
//     _videoPlayerController.dispose();
//     super.dispose();
//   }

//   void _initializeVideoPlayer() {
//     _videoPlayerController =
//         VideoPlayerController.asset('assets/wallpaper.mp4');
//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       autoPlay: true,
//       looping: false,
//       showControls: false,
//       fullScreenByDefault: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Chewie(
//             controller: _chewieController,
//           ),
//         ],
//       ),
//     );
//   }
// }
