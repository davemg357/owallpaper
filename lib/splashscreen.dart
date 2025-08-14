import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:owallpaper/colors.dart';
import 'package:owallpaper/firstpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {

int update=1;
  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState()  {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 3), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
        return FristPage();
      }));
    });
  
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Mycolors().primarycolor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Center(
            child: Image.asset(
              'lib/assets/logo22.png',
              height: 200,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Pixabay Wallpaper',
            style: TextStyle(
                fontSize: 25, fontFamily: 'Myfont', color: Colors.white),
          ),
          Spacer(),
          Container(
              padding: EdgeInsets.all(20),
              child: Image.asset(
                'lib/assets/loading4.gif',
                height: 30,
              )),
        ],
      ),
    );
  }
}
