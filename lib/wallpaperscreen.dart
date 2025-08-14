import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:owallpaper/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';

class WallpaperScreen extends StatefulWidget {
  String imageUrl;

  WallpaperScreen({required this.imageUrl});

  @override
  _WallpaperScreenState createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  bool isSettingWallpaper = false;
  var wallocation = WallpaperManager.HOME_SCREEN;
  double _progress = 0.0;

  // Method to request necessary permissions
Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    // Parse Android version as an integer
    final androidVersion = int.parse(Platform.version.split('.')[0]);

    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    if (androidVersion >= 30) {
      if (await Permission.manageExternalStorage.isDenied) {
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Storage permission is required to save images.",
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    if (await Permission.storage.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}



  void choosewallptype(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext context) {
          return Container(
         //   margin: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.2,
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
      // Use the updated widget.imageUrl after cropping
      final filePath = widget.imageUrl;

      if (filePath.isEmpty || !File(filePath).existsSync()) {
        throw Exception("File not found: $filePath");
      }

      // Set the cropped image as wallpaper
      bool success = await WallpaperManager.setWallpaperFromFile(
        filePath,
        wallocation,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wallpaper set successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to set wallpaper');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set wallpaper: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to download the image and save it to the gallery
  Future<void> downloadImage(String url) async {
    try {
      // Request permissions
      await requestPermissions();

      // Create Dio instance with progress tracking
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Update progress state
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      // Save the image to the gallery
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "downloaded_image",
      );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Failed to save image");
      }
    } catch (e) {
  // Extracting the error code using a regular expression
  final errorCode = RegExp(r'errno\s*=\s*\d+')
      .stringMatch(e.toString())
      ?.split('=')[1]
      ?.trim() ?? "Unknown Error";

  print("Error Code: $errorCode");

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: errorCode=='7'? Text("No Internet connection"):Text('Error: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
     finally {
      // Reset progress
      setState(() {
        _progress = 0.0;
      });
    }
  }

  // Method to crop the image
  Future<void> cropImage(BuildContext context) async {
    try {
      // Download the image to a temporary directory
      final tempDir = await getTemporaryDirectory();
      final localImagePath = "${tempDir.path}/temp_image.jpg";

      final response = await Dio().download(widget.imageUrl, localImagePath);

      // Ensure the image was downloaded
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to download image")),
        );
        return;
      }

      // Check if the downloaded file exists
      if (!File(localImagePath).existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Downloaded file not found"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get the screen dimensions to set as the crop area's aspect ratio
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      // Use the local file path for cropping
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: localImagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Mycolors().primarycolor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.square,
            ],
            // Custom aspect ratio for screen size
            cropFrameColor: Colors.white,
            cropGridColor: Colors.white,
            showCropGrid: true,
            activeControlsWidgetColor: Colors.white,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true, // Locks the crop area
          ),
        ],
        // Set aspect ratio to match the screen dimensions
        aspectRatio: CropAspectRatio(
          ratioX: screenWidth,
          ratioY: screenHeight,
        ),
      );

      if (croppedFile != null) {
        // Update the widget's image URL to the cropped file path
        widget.imageUrl = croppedFile.path;
        choosewallptype(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image cropping canceled"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
  // Extracting the error code using a regular expression
  final errorCode = RegExp(r'errno\s*=\s*\d+')
      .stringMatch(e.toString())
      ?.split('=')[1]
      ?.trim() ?? "Unknown Error";

  print("Error Code: $errorCode");

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: errorCode=='7'? Text("No Internet connection"):Text('Error: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size only once for performance improvement
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl,
          placeholder: (context, url) {
            return Center(
              child: Container(
                height: screenHeight * 0.2,
                width: screenWidth * 0.2,
                child: Image.asset('lib/assets/loading4.gif'),
              ),
            );
          },
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
                // Trigger the download and show progress
                downloadImage(widget.imageUrl);
                print('Download clicked');
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: screenHeight * 0.05,
                    width: screenHeight * 0.05,
                    child: Image.asset('lib/assets/download3.gif'),
                  ),
                  if (_progress > 0.0 &&
                      _progress < 1.0) // Show progress bar during download
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        width: 150, // Explicitly constrain the width
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                          minHeight: 4.0, // Adjust the height of the bar
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(),
            GestureDetector(
              onTap: () {
                cropImage(
                    context); // Trigger the crop image function before choosing wallpaper type
                print('Wallpaper applied');
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
