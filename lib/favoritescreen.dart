import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:owallpaper/appbar.dart';
import 'package:owallpaper/bottomnavigator.dart';
import 'package:owallpaper/draweritem.dart';
import 'package:owallpaper/favvoritelist.dart';
import 'package:owallpaper/wallpaperscreenlocal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favoritescreen extends StatefulWidget {
  @override
  State<Favoritescreen> createState() => _FavoritescreenState();
}

class _FavoritescreenState extends State<Favoritescreen> {
  final Favoritelist favoriteListinhere = Favoritelist();
  String? selectedlang;

  @override
  void initState() {
    super.initState();
    loadSharedPref();
    favoriteListinhere.loadFromLocalStorage().then((_) {
      setState(() {});
      print(favoriteListinhere.items);
    });
  }

  void loadSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedlang = prefs.getString('language');
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: null,
        flexibleSpace: MyAppBar(calledfrom: 'FAV'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      drawer: DrawerItem(),
      body: Column(
        children: [
          Expanded(
            child: favoriteListinhere.items.isEmpty
                ? Center(child: Image.asset('lib/assets/no-data.gif'))
                : MasonryGridView.count(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    itemCount: favoriteListinhere.items.length,
                    itemBuilder: (context, index) {
                      final imageUrl = favoriteListinhere.items[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return WallpaperScreenLocal(imageUrl: imageUrl);
                          }));
                        },
                        child: Stack(
                          children: [
                            // CachedNetworkImage to show Firebase images with cache
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error, size: 50, color: Colors.red),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            selectedlang == 'afaan oromoo'
                                                ? 'Yaadachiisa'
                                                : 'Warning!',
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                          content: Text(selectedlang ==
                                                  'afaan oromoo'
                                              ? 'Suuraa kana filatamtoota keessaa haquu barbaadduu?'
                                              : 'Do you want to remove this picture from favorite?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text(selectedlang ==
                                                      'afaan oromoo'
                                                  ? 'Lakki'
                                                  : 'No'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  favoriteListinhere
                                                      .removeItem(imageUrl);
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                selectedlang == 'afaan oromoo'
                                                    ? 'Eeyyee'
                                                    : 'Yes',
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                icon: const Icon(Icons.star),
                                color: const Color.fromARGB(255, 215, 185, 10),
                                iconSize: 35,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Bottomnavigator(calledfrom: 'FAVORITES'),
    );
  }
}
