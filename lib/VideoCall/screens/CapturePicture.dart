import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart'; // Import the permission handler

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) {
      _initializeCamera();
    });
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.storage].request();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.high,
    );

    await _controller?.initialize();
    setState(() {});

    // Start taking pictures every 5 seconds
    _startTakingPictures();
  }

  void _startTakingPictures() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (_controller != null && _controller!.value.isInitialized) {
        await _takePicture();
      }
    });
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile imageFile = await _controller!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(directory.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageFile.saveTo(imagePath);

      // Save the image to the gallery
      await GallerySaver.saveImage(imagePath);
      print('Picture saved to gallery: $imagePath');
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Camera')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: CameraPreview(_controller!),
    );
  }
}
