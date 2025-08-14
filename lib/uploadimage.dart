import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:owallpaper/appbar.dart';
import 'package:owallpaper/bottomnavigator.dart';
import 'package:owallpaper/colors.dart';
import 'package:owallpaper/draweritem.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageUploader extends StatefulWidget {
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _downloadURL;
  String? selectedlang;

  String connectionStatus = '';
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
            content: Text(selectedlang == 'afaan oromoo'
                ? 'Interneetii keessan sakatta\'aa':'Please check your internet'),
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    print('upload called');
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final imageRef = storageRef.child('uploads/$fileName.jpg');

      final uploadTask = imageRef.putFile(_imageFile!);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _uploadProgress = progress;
        });
      });

      // Wait for the upload to complete
      await uploadTask;

      // Get download URL
      final downloadURL = await imageRef.getDownloadURL();
      setState(() {
        _downloadURL = downloadURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: null,
          flexibleSpace: MyAppBar(calledfrom: 'UP'),
          automaticallyImplyLeading: false,
        ),
      drawer: DrawerItem(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            height: height * 0.4,
            width: width * 0.7,
            // decoration: BoxDecoration(color: Colors.black),
            child: _imageFile == null
                ? Image.asset(
                    'lib/assets/view.gif',
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                  ),
          ),
          if (_downloadURL != null)
            Container(
              height: height * 0.05,
              child: Text(selectedlang == 'afaan oromoo' ? 'Milkaa\'eera' :
                'Successfully Uploaded',
                style: TextStyle(color: Colors.green),
              ),
            ),

          TextButton(
            onPressed: _isUploading ? null : _pickImage,
            child: Text(selectedlang == 'afaan oromoo' ? 'Suuraa Filadhu' :'Select Image from Gallery'),
            style: TextButton.styleFrom(
                backgroundColor: Mycolors().backgroundcolor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),

          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            height: height * 0.05,
            child: TextButton(
              onPressed: () async {
                await checkInternetConnection();
                if (connectionStatus == 'NIC' || connectionStatus == 'CWI') {
                  connectiondialog();
                  print('Not connected');
                } else if (connectionStatus == 'CON') {
                  print('connected');
                  if (!_isUploading) {
                    await _uploadImage();
                  }
                }
              },
              child: _isUploading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(selectedlang == 'afaan oromoo' ? 'Olkaa\'i' :'Upload'),
              style: TextButton.styleFrom(
                  backgroundColor: Mycolors().backgroundcolor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          // Progress bar
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey[200],
                    color: Colors.blue,
                  ),
                  SizedBox(height: 8),
                  Text('${(_uploadProgress * 100).toStringAsFixed(2)}%'),
                ],
              ),
            ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
                'Do you have any wallpapers? We\'d love it if you could share them with us so we can add them to the app!',style: TextStyle(fontFamily: 'Myfont'),),
          ),
        ],
      ),
      bottomNavigationBar: Bottomnavigator(calledfrom: 'UP'),
    );
  }
}
