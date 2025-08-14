import 'dart:io';
import 'package:flutter/material.dart';
import 'package:owallpaper/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';

class WallpaperScreenLocal extends StatefulWidget {
  final String assetImagePath;

  WallpaperScreenLocal({required this.assetImagePath});

  @override
  _WallpaperScreenLocalState createState() => _WallpaperScreenLocalState();
}

class _WallpaperScreenLocalState extends State<WallpaperScreenLocal> {
  bool isSettingWallpaper = false;
  var wallocation = WallpaperManager.HOME_SCREEN;
  String? localFilePath; // Holds the cropped file path

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();

      if (await Permission.manageExternalStorage.isDenied) {
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) {
          throw Exception("Manage External Storage permission not granted");
        }
      }

      if (!status.isGranted) {
        throw Exception("Storage permission not granted");
      }
    }
  }

  void choosewallptype(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: const Color.fromARGB(255, 230, 235, 238),
        context: context,
        builder: (BuildContext context) {
          return Container(
            // margin: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.18,
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: TextButton(
                    onPressed: () {
                      wallocation = WallpaperManager.HOME_SCREEN;
                      setAsWallpaper();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Homescreen',
                        style: TextStyle(fontSize: 15),
                    ),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                       minimumSize: Size(double.infinity, 15)
                        ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: TextButton(
                    onPressed: () {
                      wallocation = WallpaperManager.LOCK_SCREEN;
                      setAsWallpaper();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Lockscreen',
                       style: TextStyle(fontSize: 15),
                    ),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 15)
                        ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: TextButton(
                    onPressed: () {
                      wallocation = WallpaperManager.BOTH_SCREEN;
                      setAsWallpaper();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Both',
                        style: TextStyle(fontSize: 15),
                    ),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                       minimumSize: Size(double.infinity, 15)
                        ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> setAsWallpaper() async {
    try {
      if (localFilePath == null) {
        throw Exception("No cropped file available");
      }

      bool success = await WallpaperManager.setWallpaperFromFile(
        localFilePath!,
        wallocation,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wallpaper set successfully!')),
        );
      } else {
        throw Exception('Failed to set wallpaper');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set wallpaper: $e')),
      );
    }
  }

  Future<void> cropImage(BuildContext context) async {
    try {
      // Get the screen's aspect ratio
      final screenSize = MediaQuery.of(context).size;
      final screenAspectRatio = screenSize.width / screenSize.height;

      // Copy the asset image to a temporary file
      final byteData =
          await DefaultAssetBundle.of(context).load(widget.assetImagePath);
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/temp_image.jpg';

      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      // Crop the image with a locked aspect ratio
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: tempFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Mycolors().primarycolor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            cropFrameStrokeWidth: 2,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          ),
        ],
        aspectRatio: CropAspectRatio(
            ratioX: screenSize.width, ratioY: screenSize.height),
      );

      if (croppedFile != null) {
        setState(() {
          localFilePath = croppedFile.path; // Save cropped file path
        });
        choosewallptype(context); // Proceed to wallpaper type selection
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cropping canceled")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during cropping: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          widget.assetImagePath,
          height: screenHeight,
          width: screenWidth,
          fit: BoxFit.cover,
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.fromLTRB(30, 20, 15, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                cropImage(context); // Trigger cropping first
              },
              child: Container(
                height: screenHeight * 0.05,
                width: screenHeight * 0.05,
                child: Image.asset('lib/assets/verified.gif'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
