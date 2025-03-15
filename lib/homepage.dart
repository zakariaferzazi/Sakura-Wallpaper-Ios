import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sakurawallpaper/custom/overViewCard.dart';
import 'package:sakurawallpaper/legalstuff/help.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ads/banneradmodel.dart';

Future<void> _launchUrl(_url) async {
  final Uri url = Uri.parse(_url);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/zakariaferzazi/Wallpapers-Jsons/master/sakuraschool.json'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        imageUrls =
            jsonResponse.map((image) => image['image'].toString()).toList();
        imageUrls = imageUrls..shuffle();
      });
    } else {
      throw Exception('Failed to load images');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final userScrollDirection = _scrollController.position.userScrollDirection;
    if (userScrollDirection == ScrollDirection.reverse && _isAppBarVisible) {
      setState(() => _isAppBarVisible = false);
    } else if (userScrollDirection == ScrollDirection.forward &&
        !_isAppBarVisible) {
      setState(() => _isAppBarVisible = true);
    }
  }

  PreferredSize? _buildAppBar() {
    if (!_isAppBarVisible) {
      return null;
    }
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        actions: [Image.asset('assets/black.jpeg')],
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 180,
                child: Image.asset(
                  'assets/appbar.png',
                  height: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.only(right: 40.0, top: 40, left: 20),
            child: SizedBox(
              child: Image.asset(
                'assets/appbar.png',
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          ListTile(
            title: Text(
              '     Help',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Help()),
              );
            },
          ),
          // ListTile(
          //   title: Text(
          //     '     Feedback',
          //     style: TextStyle(
          //       fontWeight: FontWeight.w300,
          //       color: Colors.white,
          //       fontSize: 18,
          //     ),
          //   ),
          //   onTap: () async {
          //     // Open Play Store link for feedback
          //     const url =
          //         'https://play.google.com/store/apps/details?id=com.createapp.sakurawallpaper';
          //     _launchUrl(url);
          //   },
          // ),
          // ListTile(
          //   title: Text(
          //     '     More Apps',
          //     style: TextStyle(
          //       fontWeight: FontWeight.w300,
          //       color: Colors.white,
          //       fontSize: 18,
          //     ),
          //   ),
          //   onTap: () async {
          //     // Open Play Store link for more apps
          //     const url =
          //         'https://play.google.com/store/apps/dev?id=7750748056306645879';
          //     _launchUrl(url);
          //   },
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: Column(
          children: [
            Center(child: AdBanner1()),
            Expanded(
              child: imageUrls.isEmpty
                  ? Center(child: Image.asset("assets/loading.jpg"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OverViewCard(
                                      imageUrls[index] // Pass imageUrls as well
                                      )),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: imageUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Image.asset("assets/loading.jpg"),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ));
  }
}
