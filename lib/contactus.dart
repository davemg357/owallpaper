import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owallpaper/appbar.dart';
import 'package:owallpaper/bottomnavigator.dart';
import 'package:owallpaper/colors.dart';
import 'package:owallpaper/draweritem.dart';
import 'package:owallpaper/firstpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  String connectionStatus = '';
  String? selectedlang;
  bool issending = false;
   final _formKey = GlobalKey<FormState>();
  TextEditingController namecont = TextEditingController();
   TextEditingController phonecont = TextEditingController();
    TextEditingController reasoncont = TextEditingController();
    TextEditingController emailcont = TextEditingController();
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
    void _saveInput(String name, String phonenum, String reason) async {
    try {
      setState(() {
        issending = true;
      });
      await FirebaseFirestore.instance.collection("Contact").add({
        "name": name,
        "Phone number": phonenum,
        "Reason":reason,
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
                    ? 'Waan nu quunnamtaniif galatoomaa'
                    : 'Thank you for contactin us'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return FristPage();
                        }));
                      },
                      child: Text(selectedlang == 'afaan oromoo'
                    ? 'Tole'
                    :'OK'))
                ],
              );
            });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(selectedlang == 'afaan oromoo'
              ? 'Ergameera'
              : "Sent successfully!"),
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
  Widget build(BuildContext context) {
     var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: null,
        flexibleSpace: MyAppBar(calledfrom: 'CONTACT'),
        automaticallyImplyLeading: false,
        ),
     drawer: DrawerItem(),
      body: SingleChildScrollView(
        child: Column(
          children: [
          //  MyAppBar(calledfrom: 'CONTACT'),
            Container(
              margin: EdgeInsets.all(20),
              child: Text(selectedlang=='afaan oromoo'? 'Odeeffannoo armaan gadii guutaa' :'Fill the below infromation'),),
              Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                         validator: (value) {
                          if (value == null || value.isEmpty) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Homaa hin galchine'
                                : 'This Feild can\'t be empty';
                          } else if (value.length < 2) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Maqaan keessan gabaabaadha'
                                : 'Your name is too short';
                          }
                          return null;
                        },
                        controller: namecont,
                        decoration: InputDecoration(
                            label: Text(selectedlang == 'afaan oromoo'
                                ? 'Maqaa Keessan'
                                : 'Your Name'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Mycolors().primarycolor,
                                  width: 2,
                                ))),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Homaa hin galchine'
                                : 'This Feild can\'t be empty';
                          } else if (value.length < 10) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Lakk keessan Sirrii miti'
                                : 'your phone no. is not correct';
                          }
                          return null;
                        },
                        controller: phonecont,
                        
                        decoration: InputDecoration(
                            label: Text(selectedlang == 'afaan oromoo'
                                ? 'Lakk. Bilbilaa Keessan'
                                : 'Your Phone Number'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Mycolors().primarycolor,
                                  width: 2,
                                ))),
                      ),SizedBox(height: 20),
                       TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Homaa hin galchine'
                                : 'This Feild can\'t be empty';
                          } else if (value.length < 5) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Email keessan Sirrii miti'
                                : 'Email is not correct';
                          }
                           else if (!value.contains('@')) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Fakk. Email sirrii example@gmail.com'
                                : 'Correct email format example@gmail.com';
                          }
                          return null;
                        },
                        controller: emailcont,
                        
                        decoration: InputDecoration(
                            label: Text(selectedlang == 'afaan oromoo'
                                ? 'Email Keessan'
                                : 'Your Email'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Mycolors().primarycolor,
                                  width: 2,
                                ))),
                      ), SizedBox(height: 20),
                           TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Homaa hin galchine'
                                : 'This Feild can\'t be empty';
                          } else if (value.length < 5) {
                            return selectedlang == 'afaan oromoo'
                                ? 'Sababni keessan gabaabaadha'
                                : 'Reason is too short';
                          }
                          return null;
                        },
                        controller: reasoncont,
                        
                        decoration: InputDecoration(
                            label: Text(selectedlang == 'afaan oromoo'
                                ? 'Sababa'
                                : 'Reason'),
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
                      minimumSize: Size(width * 0.2, height * 0.05),
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
                        _saveInput(namecont.text, phonecont.text,reasoncont.text);
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
                      : Text(selectedlang == 'afaan oromoo'?'Ergi':'Send')),
          ],
        ),
      ),
      bottomNavigationBar: Bottomnavigator(calledfrom: 'CONTACT'),
    );
  }
}