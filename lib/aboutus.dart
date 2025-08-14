import 'package:flutter/material.dart';
import 'package:owallpaper/appbar.dart';
import 'package:owallpaper/bottomnavigator.dart';
import 'package:owallpaper/draweritem.dart';
import 'package:owallpaper/main.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        flexibleSpace: MyAppBar(calledfrom: 'ABOUT'),
        automaticallyImplyLeading: false,
        ),
     drawer: DrawerItem(),
      body: Column(
        children: [
          Spacer(),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Pixabay Wallpaper',style: TextStyle(fontSize: 20)),
                  Text('Version 1.0.0',style: TextStyle(fontSize: 20)),
                  Text('@2025',style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
          Spacer()
        ],
      ),
      bottomNavigationBar: Bottomnavigator(calledfrom: 'About'),
    );
  }
}