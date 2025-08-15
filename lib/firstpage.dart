import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:owallpaper/appbar.dart';
import 'package:owallpaper/bottomnavigator.dart';
import 'package:owallpaper/colors.dart';
import 'package:owallpaper/draweritem.dart';
import 'package:owallpaper/favvoritelist.dart';
import 'package:owallpaper/wallpaperscreenlocal.dart';
import 'package:owallpaper/splashscreen.dart';

bool updateiscalled = false;

class FristPage extends StatefulWidget {
  const FristPage({super.key});

  @override
  State<FristPage> createState() => _FristPageState();
}

class _FristPageState extends State<FristPage> {
  String? selectedlang;
  List<String> shuffledImages = [];
  bool isclicked = false;
  int? selectedLikedIndex;
  bool loading = true;
  final Favoritelist favoriteListinhere = Favoritelist();
  List<bool> likedStatus = [];

  @override
  void initState() {
    super.initState();
    Splashscreen().update = 2;
    loadsharedpref();
    loadFavoriteList();
    loadCachedUrls();
    if (!updateiscalled) checkupdate();
  }

  /// Load favorites from local storage
  void loadFavoriteList() async {
    await favoriteListinhere.loadFromLocalStorage();
  }

  /// Load cached URLs or fetch from Firebase
  Future<void> loadCachedUrls() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cachedUrls = prefs.getStringList('wallpaper_urls');

    if (cachedUrls != null && cachedUrls.isNotEmpty) {
      shuffledImages = List.from(cachedUrls)..shuffle(); // shuffle each launch
      likedStatus = List.generate(
          shuffledImages.length,
          (index) =>
              favoriteListinhere.items.contains(shuffledImages[index]));
      setState(() => loading = false);

      // Also refresh in background to detect new images
      fetchFirebaseImages();
    } else {
      fetchFirebaseImages();
    }
  }

  /// Fetch wallpapers from Firebase Storage
  Future<void> fetchFirebaseImages() async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('wallpapers');
      final ListResult result = await storageRef.listAll();

      final List<String> urls = await Future.wait(
        result.items.map((ref) => ref.getDownloadURL()),
      );

      final existingUrls = shuffledImages.toSet();
      final newUrls = urls.where((url) => !existingUrls.contains(url)).toList();

      if (newUrls.isNotEmpty) {
        setState(() {
          shuffledImages.addAll(newUrls);
          shuffledImages.shuffle(); // shuffle old + new images

          likedStatus = List.generate(
            shuffledImages.length,
            (index) => favoriteListinhere.items.contains(shuffledImages[index]),
          );

          loading = false;
        });

        // Save updated list to cache
        final prefs = await SharedPreferences.getInstance();
        prefs.setStringList('wallpaper_urls', shuffledImages);
      } else if (loading) {
        setState(() => loading = false); // first load finished
      }
    } catch (e) {
      print('Error fetching images: $e');
      if (loading) setState(() => loading = false);
    }
  }

  /// Load language preference
  void loadsharedpref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedlang = prefs.getString('language');
    });
  }

  /// Add/remove favorites
  void addandremove(int index) {
    setState(() {
      isclicked = true;
      likedStatus[index] = !likedStatus[index];
      selectedLikedIndex = likedStatus[index] ? index : null;

      likedStatus[index]
          ? favoriteListinhere.addItem(shuffledImages[index])
          : favoriteListinhere.removeItem(shuffledImages[index]);

      favoriteListinhere.saveToLocalStorage();

      Timer(Duration(milliseconds: 2500), () {
        if (selectedLikedIndex == index) {
          setState(() => selectedLikedIndex = null);
        }
      });
    });
  }

  Future<void> checkupdate() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("update").get();
      String updateavailable = querySnapshot.docs[0]["checkupdate"].toString();
      if (updateavailable == 'yes') updatedialog();
    } catch (e) {
      print("Error checking update: $e");
    }
  }

  void updatedialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Image.asset('lib/assets/update.gif', height: 40),
        content: Text('Update available'),
        actions: [
          TextButton(onPressed: () {}, child: Text('Cancel')),
          TextButton(onPressed: () {}, child: Text('Update')),
        ],
      ),
    );
    updateiscalled = true;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: null,
        flexibleSpace: MyAppBar(calledfrom: 'FIR'),
        automaticallyImplyLeading: false,
      ),
      drawer: DrawerItem(),
      backgroundColor: const Color.fromARGB(255, 244, 239, 239),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Slider (show up to 3 images)
                if (shuffledImages.isNotEmpty)
                  Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Mycolors().primarycolor),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 2),
                        enlargeCenterPage: true,
                      ),
                      items: shuffledImages
                          .take(shuffledImages.length >= 3
                              ? 3
                              : shuffledImages.length)
                          .map((url) {
                        final fileName =
                            Uri.parse(url).pathSegments.last.split('.').first;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Positioned(
                              left: 0,
                              bottom: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.3),
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  fileName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'accentfont'),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                SizedBox(height: 10),
                Text(
                  selectedlang == 'afaan oromoo'
                      ? 'Suuraa Filadhaa'
                      : 'Choose Wallpaper',
                  style: TextStyle(
                      fontFamily: 'myfont', fontSize: 15, color: Colors.black),
                ),
                Flexible(
                  child: MasonryGridView.builder(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                    itemCount: shuffledImages.length,
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    itemBuilder: (context, index) {
                      final url = shuffledImages[index];
                      double screenWidth = MediaQuery.of(context).size.width;
                      double imageWidth = (screenWidth - 30) / 2;
                      double imageHeight = imageWidth * 1.5;

                      return GestureDetector(
                        onDoubleTap: () => addandremove(index),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return WallpaperScreenLocal(imageUrl: url);
                          }));
                        },
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              width: imageWidth,
                              height: imageHeight,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Positioned(
                              bottom: 0.2,
                              right: 0.2,
                              child: IconButton(
                                onPressed: () => addandremove(index),
                                icon: Icon(
                                  Icons.star,
                                  color: likedStatus[index]
                                      ? const Color.fromARGB(255, 215, 185, 10)
                                      : Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                            (isclicked && selectedLikedIndex == index)
                                ? Positioned.fill(
                                    child: Image.asset('lib/assets/fav2.gif'),
                                  )
                                : Container(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Bottomnavigator(calledfrom: 'FRISTPAGE'),
    );
  }
}
