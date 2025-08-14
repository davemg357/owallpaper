import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
  List<bool> likedStatus = [];
  String? selectedlang;
  void initState() {
    super.initState();
    loadsharedpref();
    // Load data from local storage and update the state
    favoriteListinhere.loadFromLocalStorage().then((_) {
      setState(() {});
      print(favoriteListinhere.items);
    });
    likedStatus =
        List.generate(favoriteListinhere.items.length, (index) => false);
  }

  void loadsharedpref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedlang = prefs.getString('language');
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: null,
        flexibleSpace: MyAppBar(
          calledfrom: 'FAV',
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      drawer: DrawerItem(),
      body: Column(
        children: [
          Container(
            height: height * 0.8,
            child: favoriteListinhere.items.isEmpty
                ? Image.asset('lib/assets/no-data.gif')
                : MasonryGridView.count(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return WallpaperScreenLocal(
                                  assetImagePath:
                                      favoriteListinhere.items[index]);
                            }));
                          },
                          child: Stack(
                            children: [
                              Image.asset(favoriteListinhere.items[index]),
                              Positioned(
                                  bottom: 0.2,
                                  right: 0.2,
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
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              content: Text(selectedlang ==
                                                      'afaan oromoo'
                                                  ? 'Suuraa kana filatamtoota keessaa haquu barbaadduu?'
                                                  : 'Do you want to remove this picture from favorite?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(selectedlang ==
                                                            'afaan oromoo'
                                                        ? 'Lakki'
                                                        : 'No')),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      favoriteListinhere
                                                          .removeItem(
                                                              favoriteListinhere
                                                                      .items[
                                                                  index]);
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    selectedlang ==
                                                            'afaan oromoo'
                                                        ? 'Eeyyee'
                                                        : 'Yes',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    icon: Icon(Icons.star),
                                    color: Color.fromARGB(255, 215, 185, 10),
                                    iconSize: 35,
                                  ))
                            ],
                          ));
                    },
                    itemCount: favoriteListinhere.items.length,
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Bottomnavigator(calledfrom: 'FAVORITES'),
    );
  }
}
