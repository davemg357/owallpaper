import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:owallpaper/colors.dart';

class WallpaperScreenLocal extends StatefulWidget {
  String imageUrl;

  WallpaperScreenLocal({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<WallpaperScreenLocal> createState() => _WallpaperScreenLocalState();
}

class _WallpaperScreenLocalState extends State<WallpaperScreenLocal> {
  bool isLoading = false;
  double _downloadProgress = 0.0;

  // Request permissions
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }
  }

  // Download image to temp (cached)
  Future<String> _downloadImage() async {
    final tempDir = await getTemporaryDirectory();
    final fileName = Uri.parse(widget.imageUrl).pathSegments.last;
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) return filePath;

    final dio = Dio();
    await dio.download(widget.imageUrl, filePath,
        onReceiveProgress: (received, total) {
      if (total != -1) {
        setState(() {
          _downloadProgress = received / total;
        });
      }
    });

    return filePath;
  }

  // Crop image with screen aspect ratio
Future<void> cropImage(BuildContext context) async {
  try {
    // First, get the cached file from the CachedNetworkImage cache
    File? imageFile;

    final cachedFile = await DefaultCacheManager().getSingleFile(widget.imageUrl)
        .catchError((_) => null);

    if (cachedFile != null && await cachedFile.exists()) {
      imageFile = cachedFile;
    } else {
      // If cache not available, download to temp directory
      final tempDir = await getTemporaryDirectory();
      final localImagePath = "${tempDir.path}/temp_image.jpg";

      final response = await Dio().download(widget.imageUrl, localImagePath);
      if (response.statusCode != 200 || !File(localImagePath).existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load image for cropping")),
        );
        return;
      }
      imageFile = File(localImagePath);
    }

    if (imageFile == null) return;

    // Get screen dimensions for aspect ratio
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
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
      widget.imageUrl = croppedFile.path;
      chooseWallpaperType(); // Call after cropping
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
        ?.trim() ?? "Unknown Error";

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


  // Wallpaper type selection
  void chooseWallpaperType() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
                onPressed: () {
                  setWallpaper(WallpaperManager.HOME_SCREEN);
                  Navigator.pop(context);
                },
                child: const Text("Homescreen")),
            TextButton(
                onPressed: () {
                  setWallpaper(WallpaperManager.LOCK_SCREEN);
                  Navigator.pop(context);
                },
                child: const Text("Lockscreen")),
            TextButton(
                onPressed: () {
                  setWallpaper(WallpaperManager.BOTH_SCREEN);
                  Navigator.pop(context);
                },
                child: const Text("Both")),
          ],
        ),
      ),
    );
  }

  // Set wallpaper
  Future<void> setWallpaper(int location) async {
    try {
      final path = await _downloadImage();
      final success = await WallpaperManager.setWallpaperFromFile(path, location);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Wallpaper set!" : "Failed to set wallpaper")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
  alignment: Alignment.center,
  children: [
    if (widget.imageUrl.startsWith("http"))
      CachedNetworkImage(
        imageUrl: widget.imageUrl,
        placeholder: (context, url) => Image.asset('lib/assets/loading4.gif'),
        errorWidget: (context, url, error) =>
            const Text("Error loading image", style: TextStyle(color: Colors.white)),
        width: screenWidth,
        height: screenHeight,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      )
    else
      Image.file(
        File(widget.imageUrl),
        width: screenWidth,
        height: screenHeight,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),

    if (_downloadProgress > 0 && _downloadProgress < 1)
      Positioned(
        bottom: 20,
        left: 50,
        right: 50,
        child: LinearProgressIndicator(
          value: _downloadProgress,
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
        ),
      ),
  ],
),
      floatingActionButton: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : FloatingActionButton(
              backgroundColor: Colors.white,
              child: const Icon(Icons.done, color: Colors.black),
              onPressed: () => cropImage(context),
            ),
    );
  }
}
