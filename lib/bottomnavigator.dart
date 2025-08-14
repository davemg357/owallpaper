import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:owallpaper/HomeScreen.dart';
import 'package:owallpaper/favoritescreen.dart';
import 'package:owallpaper/firstpage.dart';
import 'package:owallpaper/uploadimage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bottomnavigator extends StatefulWidget {
  final String calledfrom;

  Bottomnavigator({required this.calledfrom});

  @override
  State<Bottomnavigator> createState() => _BottomnavigatorState();
}

class _BottomnavigatorState extends State<Bottomnavigator> {
  String? selectedlang;
  String connectiontype = 'unknown';

  String connectionStatus = '';
  void initState() {
    // TODO: implement initState
    super.initState();
    loadsharedpref();
  }

  void loadsharedpref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedlang = prefs.getString('language');
    });
  }

  void showDataDialog() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.setString('show', 'show');
    String? dontshowagain = prefs.getString("show");
    dontshowagain != 'dont' || dontshowagain == null
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Image.asset(
                  'lib/assets/data.gif',
                  height: 50,
                ),
                content: Text(selectedlang == 'afaan oromoo'
                    ? 'Yeroo ammaa kana daataa moobaayilaa fayyadamaa jirtu, fulli amma seenuun jettaan kan marsariitti wajjin wal qabatedha'
                    : 'You are currently using mobile data, charges may apply.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                          selectedlang == 'afaan oromoo' ? 'Cufi' : 'Cancel')),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          prefs.setString("show", "dont");
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return HomeScreen();
                          }));
                        });
                      },
                      child: Text(selectedlang == 'afaan oromoo'
                          ? 'Tole, irra deebitee hin mul\'isiin'
                          : 'Okay, don\'t show again')),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return HomeScreen();
                        }));
                      },
                      child: Text(selectedlang == 'afaan oromoo'
                          ? 'Itti fufi'
                          : 'Continue')),
                ],
              );
            })
        : Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
            return HomeScreen();
          }));
    ;
  }

  Future<void> connectiondialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Image.asset(
              'lib/assets/no-internet.png',
              height: 40,
            ),
            content: Text(selectedlang == 'afaan oromoo'
                ? 'Interneetii keessan sakatta\'aa'
                : 'Please check your internet'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    selectedlang == 'afaan oromoo' ? 'Haqi' : 'Cancel',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 101, 62, 60)),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    AppSettings.openAppSettings(type: AppSettingsType.wifi);
                  },
                  child: Text(
                    selectedlang == 'afaan oromoo' ? 'Bani' : 'Check',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 69, 104, 70)),
                  )),
            ],
          );
        });
  }

  Future<void> checkInternetConnection() async {
    connectiontype = 'unknown';
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      print(connectivityResult.toString());
      if (connectivityResult.toString() == '[ConnectivityResult.mobile]') {
        setState(() {
          connectiontype = 'DATA';
        });

        print('This is coonection type: ' + connectiontype);
      }
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          connectionStatus = 'NIC';
        });
        return;
      }
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          connectionStatus = 'CON';
        });
      }
    } on SocketException catch (_) {
      setState(() {
        connectionStatus = 'CWI';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
        decoration: BoxDecoration(color: Colors.black),
        // margin: EdgeInsets.all(20),
        height: height * 0.06,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                widget.calledfrom == 'FRISTPAGE'
                    ? null
                    : Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                        return FristPage();
                      }));
              },
              icon: Icon(Icons.home),
              color:
                  widget.calledfrom == 'FRISTPAGE' ? Colors.red : Colors.white,
            ),
            IconButton(
              onPressed: () async {
                await checkInternetConnection();
                widget.calledfrom == 'HOME'
                    ? null
                    : connectionStatus == 'CON'
                        ? connectiontype == 'DATA'
                            ? showDataDialog()
                            : Navigator.pushReplacement(context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                                return HomeScreen();
                              }))
                        : connectiondialog();
              },
              icon: Icon(Icons.web_asset),
              color: widget.calledfrom == 'HOME' ? Colors.red : Colors.white,
            ),
            IconButton(
              onPressed: () {
                widget.calledfrom == 'UP'
                    ? null
                    : Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                        return ImageUploader();
                      }));
              },
              icon: Icon(Icons.upload),
              color: widget.calledfrom == 'UP' ? Colors.red : Colors.white,
            ),
            IconButton(
              onPressed: () {
                widget.calledfrom == 'FAVORITES'
                    ? null
                    : Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                        return Favoritescreen();
                      }));
              },
              icon: Icon(Icons.star),
              color:
                  widget.calledfrom == 'FAVORITES' ? Colors.red : Colors.white,
            ),
          ],
        ));
  }
}
