import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:owallpaper/HomeScreen.dart';
import 'package:owallpaper/appbar.dart';
import 'package:owallpaper/bottomnavigator.dart';
import 'package:owallpaper/colors.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:owallpaper/draweritem.dart';
import 'package:owallpaper/favvoritelist.dart';
import 'package:owallpaper/splashscreen.dart';
import 'package:owallpaper/wallpaperlist.dart';
import 'package:owallpaper/wallpaperscreen.dart';
import 'package:owallpaper/wallpaperscreenlocal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

bool updateiscalled = false;

class FristPage extends StatefulWidget {
  const FristPage({super.key});

  @override
  State<FristPage> createState() => _FristPageState();
}

class _FristPageState extends State<FristPage> {
  String? selectedlang;
  late List shuffledindex;
  bool isliked = false;
  bool isclicked = false;
  int? selectedLikedIndex;
  bool appstarted = true;
  int updatecalled = 0;
  final Favoritelist favoriteListinhere = Favoritelist();

  List<bool> likedStatus =
      List.generate(Wallpaperlist().localwallpapers.length, (index) => false);
  @override
   void didChangeDependencies() {
    super.didChangeDependencies();
        precacheImage(AssetImage('lib/assets/slideshow/abijata.jpg'), context);
    precacheImage(AssetImage('lib/assets/slideshow/dendi.jpg'), context);
    precacheImage(AssetImage('lib/assets/slideshow/portu.jpg'), context);
    }
  void initState() {
    super.initState();
    Splashscreen().update = 2;
    loadsharedpref();
    shuffledindex = List.from(Wallpaperlist().localwallpapers);
    shuffledindex.shuffle();
    favoriteListinhere.loadFromLocalStorage().then((_) {
      setState(() {
        likedStatus = shuffledindex
            .map((item) => favoriteListinhere.items.contains(item))
            .toList();
      });
    });

    if (!updateiscalled) {
      checkupdate();
    }
  }

  void updatedialod() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Image.asset(
              'lib/assets/update.gif',
              height: 40,
            ),
            content: Text('Update available'),
            actions: [
              TextButton(onPressed: () {}, child: Text('Cancel')),
              TextButton(onPressed: () {}, child: Text('Update')),
            ],
          );
        });
    updateiscalled = true;
  }

  Future<void> checkupdate() async {
    String? updateavailable;
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("update").get();
      setState(() {
        updateavailable = querySnapshot.docs[0]["checkupdate"].toString();
        if (updateavailable == 'yes') {
          updatedialod();
        }
      });

      print("update " + updateavailable.toString());
    } catch (e) {
      print("Error checking update: $e");
    }
  }

  void addandremove(int index) {
    setState(() {
      isclicked = true;
      print('selected index' + selectedLikedIndex.toString());
      print("index" + index.toString());
      print(favoriteListinhere.items);
      print(shuffledindex[index]);
      likedStatus[index] = !likedStatus[index];
      selectedLikedIndex = likedStatus[index] ? index : null;
      likedStatus[index]
          ? favoriteListinhere.addItem(shuffledindex[index])
          : favoriteListinhere.removeItem(shuffledindex[index]);
      favoriteListinhere.saveToLocalStorage();
      Timer(Duration(milliseconds: 2500), () {
        if (selectedLikedIndex == index) {
          setState(() {
            selectedLikedIndex = null;
          });
        }
      });
    });
  }

  void loadsharedpref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedlang = prefs.getString('language');
    });

    print("this is language :" + selectedlang.toString());
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var Widget = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: null,
          flexibleSpace: MyAppBar(
            calledfrom: 'FIR',
          ),
          automaticallyImplyLeading: false,
        ),
        key: _scaffoldKey,
        drawer: DrawerItem(),
        backgroundColor: const Color.fromARGB(255, 244, 239, 239),
        body: Column(children: [
          Container(
              decoration: BoxDecoration(color: Mycolors().primarycolor),
              margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
              padding: EdgeInsets.all(2),
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true, // Enable autoplay
                  autoPlayInterval:
                      Duration(seconds: 2), // Set the interval between slides
                  enlargeCenterPage:
                      true, // Optional: enlarge the current slide
                  onPageChanged: (index, reason) {
                    print(index); // You can track the current index if needed
                  },
                ),
                items: [
                  // First slide
                  Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'lib/assets/slideshow/abijata.jpg',
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'Abijata Shalla National Park',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'accentfont'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Second slide
                  Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'lib/assets/slideshow/dendi.jpg',
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'Dendi Crater Lake',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'accentfont'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Third slide
                  Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'lib/assets/slideshow/portu.jpg',
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'Portuguese Bridge',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'accentfont'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              selectedlang.toString() == 'afaan oromoo'
                  ? 'Suuraa Filadhaa'
                  : 'Choose Wallpaper',
              style: TextStyle(
                  fontFamily: 'myfont', fontSize: 15, color: Colors.black),
            ),
          ),
          Flexible(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                height: height * 0.55,
                child: MasonryGridView.count(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  crossAxisCount: 2, // Two items per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemCount: shuffledindex.length,
                  itemBuilder: (context, index) {
                    // Get the screen size
                    double screenWidth = MediaQuery.of(context).size.width;
                    double screenHeight = MediaQuery.of(context).size.height;

                    // Set image size based on screen width and height
                    double imageWidth = (screenWidth - 3 * 10) /
                        2; // 2 items per row, minus spacing
                    double imageHeight =
                        imageWidth * 1.5; // Adjust this ratio for height

                    return GestureDetector(
                      onDoubleTap: () {
                        addandremove(index);
                      },
                      onTap: () {
                        // Navigate to detail view with the original image
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return WallpaperScreenLocal(
                            assetImagePath:
                                shuffledindex[index], // Full-resolution image
                          );
                        }));
                      },
                      child: Stack(
                        children: [
                          // Use low resolution for grid images
                          Image.asset(
                            shuffledindex[index],
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            width: imageWidth,
                            height: imageHeight,
                            cacheWidth: imageWidth
                                .toInt(), // Cache at the desired width
                            cacheHeight: imageHeight
                                .toInt(), // Cache at the desired height
                          ),
                          Positioned(
                            bottom: 0.2,
                            right: 0.2,
                            child: IconButton(
                              onPressed: () {
                                addandremove(index);
                              },
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
                              ? Positioned(
                                  bottom: 0,
                                  top: 0,
                                  right: 0,
                                  left: 0,
                                  child: Image.asset('lib/assets/fav2.gif'),
                                )
                              : Container(),
                        ],
                      ),
                    );
                  },
                )),
          ),
        ]),
        bottomNavigationBar: Bottomnavigator(calledfrom: 'FRISTPAGE'));
  }
}
