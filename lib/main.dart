import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:owallpaper/HomeScreen.dart';
import 'package:owallpaper/apirequest.dart';
import 'package:owallpaper/firstpage.dart';
import 'package:owallpaper/splashscreen.dart';

void main() { 
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
       fontFamily: 'Myfont3',
      ),
      debugShowCheckedModeBanner: false,
      home: Splashscreen(),
    );
  }
}
