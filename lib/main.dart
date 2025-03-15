import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sakurawallpaper/splashScreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
  tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,  // Yes for child-directed apps
  tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,  // GDPR underage consent
  ));
  MobileAds.instance.initialize();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreenPage()
        // Add other routes here
      },
    );
  }
}
