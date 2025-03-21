import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../ads/ineterstitialmodel.dart';

class OverViewCard extends StatefulWidget {
  final String imageurl;

  const OverViewCard(this.imageurl);

  @override
  _OverViewCardState createState() => _OverViewCardState();
}

class _OverViewCardState extends State<OverViewCard> {
  Future<void> _setWallpaper(BuildContext context) async {
    // Platform-specific implementation
    if (Platform.isAndroid) {
      await _setWallpaperAndroid(context);
    } else if (Platform.isIOS) {
      await _setWallpaperIOS(context);
    }
  }

  Future<void> _setWallpaperAndroid(BuildContext context) async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    final status = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;
        
    if (status == PermissionStatus.granted) {
      try {
        final File cachedImage =
            await DefaultCacheManager().getSingleFile(widget.imageurl);

        final WallpaperScreen selectedScreen = await _showScreenSelectionDialog(context);
        int wallpaperType = WallpaperManager.HOME_SCREEN; // Default value

        if (selectedScreen == WallpaperScreen.HOME_SCREEN) {
          wallpaperType = WallpaperManager.HOME_SCREEN;
        } else if (selectedScreen == WallpaperScreen.LOCK_SCREEN) {
          wallpaperType = WallpaperManager.LOCK_SCREEN;
        } else if (selectedScreen == WallpaperScreen.BOTH_SCREENS) {
          wallpaperType = WallpaperManager.BOTH_SCREEN;
        }

        final bool result = await WallpaperManager.setWallpaperFromFile(
          cachedImage.path,
          wallpaperType,
        );

        _showResultSnackbar(context, result);
      } catch (e) {
        _showErrorSnackbar(context, e.toString());
      }
    } else {
      _showPermissionDeniedSnackbar(context);
    }
  }

  Future<void> _setWallpaperIOS(BuildContext context) async {
    // For iOS, we use a different approach that doesn't require photo library permissions
    try {
      // Show loading indicator
      _showLoadingDialog(context);
      
      // Download the image to temporary directory
      final File cachedImage = await DefaultCacheManager().getSingleFile(widget.imageurl);
      
      // Create a temporary file with a proper extension
      final tempDir = await getTemporaryDirectory();
      final String fileName = 'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File tempFile = File('${tempDir.path}/$fileName');
      
      // Copy the image to the temporary file
      await cachedImage.copy(tempFile.path);
      
      // Remove loading dialog
      Navigator.of(context).pop();
      final box = context.findRenderObject() as RenderBox?;
      // Share the image file
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Save this image and set as wallpaper',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      
      // Show instructions
      await _showIOSInstructionsDialog(context);
      
    } catch (e) {
      // If loading dialog is showing, close it
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorSnackbar(context, e.toString());
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text("Preparing image..."),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showIOSInstructionsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set as Wallpaper'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To set as wallpaper:'),
              SizedBox(height: 8),

Text('1. Save image'),  
Text('2. Open the Photos app'),  
Text('3. Find and tap on the saved image'),  
Text('4. Tap the share icon (box with arrow)'),  
Text('5. Scroll and select "Use as Wallpaper"'),  
Text('6. Adjust the image as needed'),  
Text('7. Choose where to set it (Home, Lock, or Both)'),  

            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<WallpaperScreen> _showScreenSelectionDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Screen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Home Screen'),
                onTap: () {
                  Navigator.of(context).pop(WallpaperScreen.HOME_SCREEN);
                },
              ),
              ListTile(
                title: const Text('Lock Screen'),
                onTap: () {
                  Navigator.of(context).pop(WallpaperScreen.LOCK_SCREEN);
                },
              ),
              ListTile(
                title: const Text('Both'),
                onTap: () {
                  Navigator.of(context).pop(WallpaperScreen.BOTH_SCREENS);
                },
              ),
            ],
          ),
        );
      },
    ) ?? WallpaperScreen.HOME_SCREEN; // Default value if dialog is dismissed
  }

  void _showResultSnackbar(BuildContext context, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              success 
                  ? 'Wallpaper added to your screen!' 
                  : 'Failed to set wallpaper.',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error: $errorMessage',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPermissionDeniedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Permission denied. Wallpaper cannot be set.',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Center(
              child: Icon(
                Icons.close,
                weight: 10,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(widget.imageurl),
            fit: BoxFit.cover,
          ),
        ),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Spacer(),
                    Builder(
                      builder: (context) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          height: 50,
                          width: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              AdInterstitial1.loadInterstialAd();
                              AdInterstitial1.showInterstitialAd();
                              _setWallpaper(context);
                            },
                            child: const Text(
                              "Set as Wallpaper",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                    Spacer()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum WallpaperScreen {
  HOME_SCREEN,
  LOCK_SCREEN,
  BOTH_SCREENS,
}