import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:owallpaper/HomeScreen.dart';
import 'package:owallpaper/appbar.dart';
import 'package:owallpaper/bottomnavigator.dart';
import 'package:owallpaper/colors.dart';
import 'package:owallpaper/draweritem.dart';
import 'package:owallpaper/firstpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String connectionStatus = '';
  String? selectedlang;
  @override
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

  Future<void> connectiondialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Image.asset(
              'lib/assets/no-internet.png',
              height: 40,
            ),
            content: Text(selectedlang == 'english'
                ? 'Please check your internet'
                : 'Interneetii keessan sakatta\'aa'),
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
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
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

  void _saveInput(String name, String feedback) async {
    try {
      setState(() {
        issending = true;
      });
      await FirebaseFirestore.instance.collection("Feedback").add({
        "name": name,
        "Feedback": feedback,
        "timestamp": DateTime.now().toIso8601String(),
      });
      setState(() {
        issending = false;
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  selectedlang == 'afaan oromoo' ? 'Milkaa\'eera' : 'Success!',
                  style: TextStyle(color: Colors.green),
                ),
                content: Text(selectedlang == 'afaan oromoo'
                    ? 'Yaada nuu laattaniif galatoomaa'
                    : 'Thanks for sharing your feedback'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return FristPage();
                        }));
                      },
                      child:
                          Text(selectedlang == 'afaan oromoo' ? 'Tole' : 'OK'))
                ],
              );
            });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(selectedlang == 'afaan oromoo'
              ? 'Ergameera'
              : "Feedback sent successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool issending = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController namecont = TextEditingController();
  TextEditingController feedbackcont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: null,
          flexibleSpace: MyAppBar(calledfrom: 'FEEDBACK'),
          automaticallyImplyLeading: false,
        ),
        drawer: DrawerItem(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    selectedlang == 'afaan oromoo'
                        ? 'Yaada Ergaa'
                        : 'Send Feedback',
                    style: TextStyle(fontSize: 25, fontFamily: 'Myfont'),
                  )),
              Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextField(
                        controller: namecont,
                        decoration: InputDecoration(
                            label: Text(selectedlang == 'afaan oromoo'
                                ? 'Maqaa'
                                : 'Name(Optional)'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Mycolors().primarycolor,
                                  width: 2,
                                ))),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Homaa hin galchine'
                                : 'This Feild can\'t be empty';
                          } else if (value.length < 5) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Yaadni keessan gabaabaadha'
                                : 'Feedback is too short';
                          }
                          return null;
                        },
                        controller: feedbackcont,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: InputDecoration(
                            label: Text(selectedlang == 'afaan oromoo'
                                ? 'Yaada'
                                : 'Feedback'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Mycolors().primarycolor,
                                  width: 2,
                                ))),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Mycolors().backgroundcolor,
                      foregroundColor: Colors.white,
                      //maximumSize: Size(5, 25),
                     // minimumSize: Size(width * 0.2, height * 0.05),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    await checkInternetConnection();
                    print(connectionStatus);
                    if (_formKey.currentState!.validate()) {
                      if (connectionStatus == 'NIC' ||
                          connectionStatus == 'CWI') {
                        connectiondialog();
                      } else if (connectionStatus == 'CON') {
                        _saveInput(namecont.text, feedbackcont.text);
                        print('sending');
                      }
                    }
                  },
                  child: issending
                      ? Image.asset(
                          'lib/assets/loading4.gif',
                          height: 30,
                          width: 30,
                        )
                      : Text(selectedlang == 'afaan oromoo' ? 'Ergi' : 'Send')),
              //Spacer(),
            ],
          ),
        ),
        bottomNavigationBar: Bottomnavigator(calledfrom: 'FEEDBACK'),
        floatingActionButton: FloatingActionButton(
          child: Image.asset('lib/assets/info.gif'),
          isExtended: true,
          onPressed: () {
            showMenu(
                context: context,
                position:
                    RelativeRect.fromLTRB(0, height - height * 0.38, width, 0),
                items: [
                  PopupMenuItem(
                    child: Text(
                      'Your feedback is incredibly important to us as we strive to create a better app experience for you. We would love to hear your thoughts, suggestions, or any bugs you may have encountered while using the app. Your input helps us improve and provide the best possible service. Thank you for taking the time to share your feedback!',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontFamily: 'Myfont', fontSize: 20),
                    ),
                    onTap: () {
                      print('English');
                    },
                  ),
                ]);
          },
        ));
  }
}
