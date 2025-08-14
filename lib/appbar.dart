import 'package:flutter/material.dart';
import 'package:owallpaper/aboutus.dart';
import 'package:owallpaper/colors.dart';
import 'package:owallpaper/contactus.dart';
import 'package:owallpaper/favoritescreen.dart';
import 'package:owallpaper/feedback.dart';
import 'package:owallpaper/firstpage.dart';
import 'package:owallpaper/uploadimage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatefulWidget {
  var calledfrom;
  MyAppBar({required this.calledfrom});

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  String? choosedlang;
  String? selectedlang;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadsharedpref();
  }

  void setpreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  void loadsharedpref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedlang = prefs.getString('language');
    });
  }

  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
     // padding: EdgeInsets.only(top: 40),
      height: height * 0.11,
      width: double.infinity,
      decoration: BoxDecoration(color: Mycolors().primarycolor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              )),
          Text(
            (widget.calledfrom == 'FIR')
                ? 'Pixabay Wallpaper'
                : (widget.calledfrom == 'UP')
                    ? (selectedlang.toString() == 'afaan oromoo')
                        ? 'Qooduu'
                        : 'Upload'
                    : (widget.calledfrom == 'FEEDBACK')
                        ? (selectedlang.toString() == 'afaan oromoo')
                            ? 'Yaada'
                            : 'Feedback'
                        : (widget.calledfrom == 'ABOUT')
                            ? (selectedlang.toString() == 'afaan oromoo')
                                ? 'Waa\'ee Keenya'
                                : 'About us'
                            : (widget.calledfrom == 'FAV')
                                ? (selectedlang.toString() == 'afaan oromoo')
                                    ? 'Filatamaa'
                                    : 'Favorite'
                                : (widget.calledfrom == 'CONTACT')
                                ? (selectedlang.toString() == 'afaan oromoo')
                                    ? 'Nu Quunnamaa'
                                    : 'Contact Us':'',
            style: TextStyle(
                color: Colors.white, fontFamily: 'myfont', fontSize: 20),
          ),
          IconButton(
              onPressed: () {
                showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(100, 100, 0, 0),
                    items: [
                      PopupMenuItem(
                        child: Text('English'),
                        onTap: () {
                          widget.calledfrom == 'FIR'
                              ? Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) {
                                  return FristPage();
                                }))
                              : widget.calledfrom == 'FEEDBACK'
                                  ? Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) {
                                      return FeedbackScreen();
                                    }))
                                  : widget.calledfrom == 'UP'
                                      ? Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                          return ImageUploader();
                                        }))
                                      : widget.calledfrom == 'FAV'
                                          ? Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                              return Favoritescreen();
                                            }))
                                          : widget.calledfrom == 'ABOUT'
                                              ? Navigator.of(context)
                                                  .pushReplacement(MaterialPageRoute(
                                                      builder: (BuildContext context) {
                                                  return AboutUs();
                                                }))
                                              : widget.calledfrom == 'CONTACT'
                                              ? Navigator.of(context)
                                                  .pushReplacement(MaterialPageRoute(
                                                      builder: (BuildContext context) {
                                                  return ContactUs();
                                                }))
                                              : null;;
                          ;
                          setState(() {
                            setpreference('english');
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: Text('Afaan Oromoo'),
                        onTap: () {
                          widget.calledfrom == 'FIR'
                              ? Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) {
                                  return FristPage();
                                }))
                              : widget.calledfrom == 'FEEDBACK'
                                  ? Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) {
                                      return FeedbackScreen();
                                    }))
                                  : widget.calledfrom == 'UP'
                                      ? Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                          return ImageUploader();
                                        }))
                                      : widget.calledfrom == 'FAV'
                                          ? Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                              return Favoritescreen();
                                            }))
                                          : widget.calledfrom == 'ABOUT'
                                              ? Navigator.of(context)
                                                  .pushReplacement(MaterialPageRoute(
                                                      builder: (BuildContext context) {
                                                  return AboutUs();
                                                }))
                                              : widget.calledfrom == 'CONTACT'
                                              ? Navigator.of(context)
                                                  .pushReplacement(MaterialPageRoute(
                                                      builder: (BuildContext context) {
                                                  return ContactUs();
                                                }))
                                              : null;;
                          setState(() {
                            setpreference('afaan oromoo');
                          });
                        },
                      ),
                    ]);
              },
              icon: Icon(
                Icons.language_outlined,
                color: Colors.white,
              ))
        ],
      ),
    );
  }
}
