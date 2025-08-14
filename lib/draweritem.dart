import 'package:flutter/material.dart';
import 'package:owallpaper/HomeScreen.dart';
import 'package:owallpaper/aboutus.dart';
import 'package:owallpaper/colors.dart';
import 'package:owallpaper/contactus.dart';
import 'package:owallpaper/feedback.dart';
import 'package:owallpaper/uploadimage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerItem extends StatefulWidget {
  const DrawerItem({super.key});

  @override
  State<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem> {
  @override
  String? selectedlang;
  void initState() {
    // TODO: implement initState
    super.initState();
    loadsharedpref();
        
  }
  void loadsharedpref ()async{
final prefs =  await SharedPreferences.getInstance();
setState(() {
   selectedlang =   prefs.getString('language');
});
   
    print("this is language :" +selectedlang.toString());
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Mycolors().primarycolor),
              child: Center(
                  child: Text(
                'Pixabay Wallpaper',
                style: TextStyle(color: Colors.white, fontFamily: 'Myfont'),
              ))),
          ListTile(
            onTap: () {
              print('Tapped');
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                return ImageUploader();
              }));
            //  Navigator.of(context).pop();
            },
            tileColor: Mycolors().primarycolor.withOpacity(0.1),
            leading: Icon(Icons.share),
            title:  Text(selectedlang.toString()=='afaan oromoo'? 'Wallpaper kee qoodi':'Share Your Wallpaper'),
          ),
          SizedBox(height: 2),
          ListTile(
            onTap: () {
              print('Tapped');
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                return FeedbackScreen();
              }));
           //Navigator.of(context).pop();
            },
            tileColor: Mycolors().primarycolor.withOpacity(0.1),
            leading: Icon(Icons.feedback),
            title: Text(selectedlang.toString()=='afaan oromoo'?'Yaada':'Feedback'),
          ),
          SizedBox(height: 2),
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                return AboutUs();
              }));
              print('Tapped');
              //Navigator.of(context).pop();
            },
            tileColor: Mycolors().primarycolor.withOpacity(0.1),
            leading: Icon(Icons.info),
            title: Text(selectedlang.toString()=='afaan oromoo'?'Waa\'ee Keenya':'About Us'),
          ),
           SizedBox(height: 2),
             ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                return ContactUs();
              }));
              print('Tapped');
              //Navigator.of(context).pop();
            },
            tileColor: Mycolors().primarycolor.withOpacity(0.1),
            leading: Icon(Icons.phone),
            title: Text(selectedlang.toString()=='afaan oromoo'?'Nu quunnamaa':'Contact us'),
          ),
        ],
      ),
    );
  }
}
