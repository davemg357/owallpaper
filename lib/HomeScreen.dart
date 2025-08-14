import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:owallpaper/apirequest.dart';
import 'package:owallpaper/bottomnavigator.dart';
import 'package:owallpaper/colors.dart';
import 'package:owallpaper/wallpaperscreen.dart';
import 'package:translator/translator.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchquery = TextEditingController();
  List wallpapers = [];
  bool isLoading = false;
  String intitialsc = '';
  final List<String> buttonlabels = ['Nature','Animal','Birds','Mountain','Sunset'];
  int selectedindex=-1;

  @override
  void initState() {
    super.initState();
    List<String> intitialscls = [
      'Birds',
      'Animal',
      'mountain',
      'nature',
      'sunset',
      'flower'
    ];
    intitialsc = intitialscls[Random().nextInt(intitialscls.length)];
    loadWallpapers(intitialsc);
  }

  void refreshscreen() {
    loadWallpapers(intitialsc);

    setState(() {
      print('screen refreshed');
    });
  }

  void nointernernet() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Check Internet',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Please connect to the internet to load wallpapers!',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                AppSettings.openAppSettings(
                    type: AppSettingsType.wifi); // Close the dialog
              },
              child: const Text(
                'Turn on',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  void loadWallpapers(String query) async {
    try {
      final List data = await fetchWallpapers(query);
      setState(() {
        wallpapers = data;
        wallpapers.shuffle();
        isLoading = false;
      });
    } catch (e) {
      print("This is error" + e.toString());
      nointernernet();
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Mycolors().primarycolor,
          title: Text(
            'Pixabay Wallpaper',
            style: TextStyle(color: Colors.white, fontFamily: 'Myfont'),
          ),
          centerTitle: true,
          bottom: PreferredSize(
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
              child: Column(children: [
                Container(
                  margin: EdgeInsets.all(5),
                  height: 40,
                  child: TextField(
                      controller: searchquery,
                      onChanged: (value) {
                        setState(() {
                          loadWallpapers(searchquery.text);
                        });
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          labelText: 'Search',
                          
                          labelStyle: TextStyle(
                             color: Colors.white.withOpacity(0.8),
                              fontFamily: 'Myfont'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                               color: Colors.white.withOpacity(0.5),
                                width: 2,
                              )))),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                        buttonlabels.length,
                        (index){
                          return Container(
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 2),
                            child: TextButton(onPressed: () { 
                              setState(() {
                                if(selectedindex==index){
                                  return;
                                }
                                loadWallpapers(buttonlabels[index]);
                                selectedindex=index;
                              });
                            },
                            
                            child: Container(
                              padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                              child: Text(buttonlabels[index])),
                            style: TextButton.styleFrom( 
                            backgroundColor: selectedindex==index?Colors.white: Mycolors().primarycolor,
                            foregroundColor:selectedindex==index? Colors.black:Colors.white.withOpacity(0.7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: BorderSide(color: Colors.white)
                             ) ),
                          );
                        }
                      ),
                      
                    //   Container(
                    //     padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    //     child: TextButton(onPressed: (){}, child: Container(
                    //       padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                    //       child: Text('Nature')),style: TextButton.styleFrom(
                    //       backgroundColor: Mycolors().primarycolor,
                    //       foregroundColor: Colors.white.withOpacity(0.7),
                    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    //       side: BorderSide(color: Colors.white)
                        
                    //     ),),
                    //   ),
                      
                    //   GestureDetector(
                    //     onTap: () {
                    //       setState(() {
                    //         loadWallpapers('Animal');
                    //         print('tapped');
                    //       });
                    //     },
                    //     child: Tabbaritem(querytitle: 'Animal',color: Colors.purple,),
                    //   ),
                    //   GestureDetector(
                    //     onTap: () {
                    //       setState(() {
                    //         loadWallpapers('Bird');
                    //         print('tapped');
                    //       });
                    //     },
                    //     child: Tabbaritem(querytitle: 'Bird',color: Colors.white),
                    //   ),
                    //   GestureDetector(
                    //     onTap: () {
                    //       setState(() {
                    //         loadWallpapers('Mountain');
                    //         print('tapped');
                    //       });
                    //     },
                    //     child: Tabbaritem(querytitle: 'Mountain',color: Colors.blue,),
                    //   ),
                    // ],
                  ),
                ),
              ])),
        ),
        body: isLoading
            ? SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: EdgeInsets.fromLTRB(
                            0, MediaQuery.of(context).size.height * 0.1, 0, 0),
                        child: Image.asset('lib/assets/no-data.gif')),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0, MediaQuery.of(context).size.height * 0.1, 0, 0),
                      child: TextButton(
                        onPressed: () {
                          refreshscreen();
                        },
                        child: Text('Retry'),
                        style: TextButton.styleFrom(
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.3,
                                MediaQuery.of(context).size.height * 0.04),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Mycolors().backgroundcolor,
                            foregroundColor: Mycolors().foregroundColor),
                      ),
                    ),
                  ],
                ),
              )
            : MasonryGridView.count(
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                itemCount: wallpapers.length,
                itemBuilder: (context, index) {
                  final wallpaper = wallpapers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WallpaperScreen(
                            imageUrl: wallpaper['largeImageURL'],
                          ),
                        ),
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: wallpaper['largeImageURL'],
                      placeholder: (context, url) => Center(
                          child: Container(
                              margin: EdgeInsets.all(60),
                              child: Image.asset('lib/assets/loadin2.gif'))),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
        bottomNavigationBar: Bottomnavigator(calledfrom: 'HOME'));
  }
}
