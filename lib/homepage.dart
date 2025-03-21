import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sakurawallpaper/custom/overViewCard.dart';
import 'package:sakurawallpaper/legalstuff/help.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
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
  List<String> favorites = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadFavorites();
    fetchImageUrls();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> _toggleFavorite(String url) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favorites.contains(url)) {
        favorites.remove(url);
      } else {
        favorites.add(url);
      }
    });
    await prefs.setStringList('favorites', favorites);
  }

  Future<void> fetchImageUrls() async {
    try {
      final response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/zakariaferzazi/Wallpapers-Jsons/master/sakuraschool.json'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          imageUrls =
              jsonResponse.map((image) => image['image'].toString()).toList();
          imageUrls.shuffle();
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  List<String> get filteredImages {
    if (_searchQuery.isEmpty) return imageUrls;
    return imageUrls
        .where((url) => url.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.white),
          onPressed: () {
            // Add refresh functionality
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FavoritesScreen(favorites: favorites)));
          },
        ),
      ],
      backgroundColor: Colors.black,
      centerTitle: true,
      title: LayoutBuilder(
        builder: (context, constraints) {
          // Get device width
          double deviceWidth = MediaQuery.of(context).size.width;
          
          // Calculate responsive image width
          // Smaller percentage for tablets, larger for phones
          double imageWidth = deviceWidth < 600 ? 
                       deviceWidth :    // iPhone or smaller devices
                       deviceWidth * 0.25;    // iPad or larger devices
          
          return Image.asset(
            'assets/appbar.png',
            width: imageWidth,
            fit: BoxFit.contain,
          );
        }
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
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/screenshot.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            ),
          ),
          _buildDrawerItem(
              Icons.help,
              'Help',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Help()))),
          _buildDrawerItem(
              Icons.star,
              'Rate App',
              () => _launchUrl(
                  'https://apps.apple.com/us/app/Sakura-Wallpapers-School/id6743289362')),
          _buildDrawerItem(
              Icons.share,
              'Share App',
              () => _launchUrl(
                  'https://apps.apple.com/us/app/Sakura-Wallpapers-School/id6743289362')),
          _buildDrawerItem(
              Icons.favorite,
              'Favorites',
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FavoritesScreen(favorites: favorites)))),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildImageGrid() {
    return RefreshIndicator(
      onRefresh: fetchImageUrls,
      child: GridView.builder(
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
                    builder: (context) =>
                        OverViewCard(imageUrls[index] // Pass imageUrls as well
                            )),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
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
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                Positioned(
                  top: 0, // Distance from the top
                  right: 0, // Distance from the right
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.7), // Background color of the circle
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        favorites.contains(imageUrls[index])
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => _toggleFavorite(imageUrls[index]),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchImageUrls, // Refresh functionality
        backgroundColor: Colors.red, // Match your app's theme
        child: Icon(Icons.refresh, color: Colors.white), // Refresh icon
      ),
      body: Column(
        children: [
          AdBanner1(),
          Expanded(
            child: _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Failed to load images',
                            style: TextStyle(color: Colors.white)),
                        ElevatedButton(
                          child: Text('Retry'),
                          onPressed: fetchImageUrls,
                        ),
                      ],
                    ),
                  )
                : _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredImages.isEmpty
                        ? Center(
                            child: Text('No wallpapers found',
                                style: TextStyle(color: Colors.white)),
                          )
                        : _buildImageGrid(),
          ),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  final List<String> favorites;
  final Function(String)? onRemoveFavorite;

  const FavoritesScreen({
    required this.favorites,
    this.onRemoveFavorite,
    Key? key,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Favorites'),
        actions: [
          if (widget.favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.favorites.isEmpty) {
      return _buildEmptyState();
    }
    return _buildFavoriteGrid();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on wallpapers to add them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.65,
        ),
        itemCount: widget.favorites.length,
        itemBuilder: (context, index) {
          final imageUrl = widget.favorites[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OverViewCard(imageUrl // Pass imageUrls as well
                            )),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Image.asset("assets/loading.jpg"),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                Positioned(
                  top: 0, // Distance from the top
                  right: 0, // Distance from the right
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red
                          .withOpacity(0.7), // Background color of the circle
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () => _removeFavorite(imageUrl),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),

    );
  }



  void _toggleFavorite(String imageUrl) {
    setState(() {
      if (widget.favorites.contains(imageUrl)) {
        widget.favorites.remove(imageUrl);
      } else {
        widget.favorites.add(imageUrl);
      }
    });
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text('Are you sure you want to remove all favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllFavorites();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _removeFavorite(String imageUrl) {
    _toggleFavorite(imageUrl);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            widget.favorites.add(imageUrl);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesScreen(
                  favorites: widget.favorites,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _clearAllFavorites() {
    widget.favorites.clear();
    Navigator.pop(context);
  }
}


