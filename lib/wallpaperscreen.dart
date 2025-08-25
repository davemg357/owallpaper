import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:owallpaper/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
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
  var wallocation = WallpaperManagerFlutter.homeScreen;
  double _progress = 0.0;

  File? _croppedFile; // store cropped image file

  // Method to request necessary permissions
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
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
            height: MediaQuery.of(context).size.height * 0.2,
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: TextButton(
                    onPressed: () {
                      wallocation = WallpaperManagerFlutter.homeScreen;
                      setAsWallpaper();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Homescreen',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 15)),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: TextButton(
                    onPressed: () {
                      wallocation = WallpaperManagerFlutter.lockScreen;
                      setAsWallpaper();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Lockscreen',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 15)),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: TextButton(
                    onPressed: () {
                      wallocation = WallpaperManagerFlutter.bothScreens;
                      setAsWallpaper();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Both',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 15)),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> setAsWallpaper() async {
    setState(() => isSettingWallpaper = true);

    try {
      File file;

      if (_croppedFile != null) {
        file = _croppedFile!;
      } else {
        final tempDir = await getTemporaryDirectory();
        final localPath = "${tempDir.path}/wall.jpg";
        await Dio().download(widget.imageUrl, localPath);
        file = File(localPath);
      }

      final wallpaperManager = WallpaperManagerFlutter();
      await wallpaperManager.setWallpaper(file, wallocation);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wallpaper set successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set wallpaper: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSettingWallpaper = false);
    }
  }

  // Method to download the image and save it to the gallery
  Future<void> downloadImage(String url) async {
    try {
      await requestPermissions();

      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

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
      final errorCode = RegExp(r'errno\s*=\s*\d+')
              .stringMatch(e.toString())
              ?.split('=')[1]
              ?.trim() ??
          "Unknown Error";

      print("Error Code: $errorCode");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: errorCode == '7'
              ? Text("No Internet connection")
              : Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _progress = 0.0;
      });
    }
  }

  // Method to crop the image
  Future<void> cropImage(BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final localImagePath = "${tempDir.path}/temp_image.jpg";

      final response = await Dio().download(widget.imageUrl, localImagePath);

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to download image")),
        );
        return;
      }

      if (!File(localImagePath).existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Downloaded file not found"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

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
            cropFrameColor: Colors.white,
            cropGridColor: Colors.white,
            showCropGrid: true,
            activeControlsWidgetColor: Colors.white,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          ),
        ],
        aspectRatio: CropAspectRatio(
          ratioX: screenWidth,
          ratioY: screenHeight,
        ),
      );

      if (croppedFile != null) {
        setState(() {
          _croppedFile = File(croppedFile.path);
        });
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
      final errorCode = RegExp(r'errno\s*=\s*\d+')
              .stringMatch(e.toString())
              ?.split('=')[1]
              ?.trim() ??
          "Unknown Error";

      print("Error Code: $errorCode");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: errorCode == '7'
              ? Text("No Internet connection")
              : Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
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
        child: _croppedFile != null
            ? Image.file(_croppedFile!)
            : CachedNetworkImage(
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
                  if (_progress > 0.0 && _progress < 1.0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        width: 150,
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                          minHeight: 4.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(),
            GestureDetector(
              onTap: () {
                cropImage(context);
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
