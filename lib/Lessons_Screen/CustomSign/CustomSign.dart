import 'package:camera/camera.dart';
import 'package:cbsp_flutter_app/Lessons_Screen/CustomSign/UplaodCustomSign.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class CustomSign extends StatefulWidget {
  @override
  _CustomSignState createState() => _CustomSignState();
}

class _CustomSignState extends State<CustomSign> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  List<File> capturedImages = [];
  int currentImageIndex = 0;
  bool isCountingDown = false;
  bool isTakingImages = false;
  int countdown = 3;
  bool showFlash = false;
  bool showReadyMessage = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(
      cameras!.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.high,
    );
    await controller?.initialize();
    setState(() {});
  }

  Future<void> startCountdown() async {
    setState(() {
      isCountingDown = true;
      showReadyMessage = true;
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      showReadyMessage = false;
      countdown = 3;
    });
    for (int i = 3; i > 0; i--) {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        countdown = i - 1;
      });
    }
    setState(() {
      isCountingDown = false;
      isTakingImages = true;
    });
    startTakingImages();
  }

  Future<void> startTakingImages() async {
    for (int i = 0; i < 5; i++) {
      await takePicture();
      if (i < 4) {
        setState(() {
          showReadyMessage = true;
        });
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          showReadyMessage = false;
          countdown = 3;
        });
        for (int j = 3; j > 0; j--) {
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            countdown = j - 1;
          });
        }
      }
    }
    setState(() {
      isTakingImages = false;
    });
  }

  Future<void> takePicture() async {
    if (!controller!.value.isInitialized) {
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    final filePath = join(directory.path, '${DateTime.now()}.png');
    if (controller!.value.isTakingPicture) {
      return;
    }
    try {
      setState(() {
        showFlash = true;
      });
      final XFile picture = await controller!.takePicture();
      final File imageFile = File(picture.path);
      await imageFile.copy(filePath);
      setState(() {
        capturedImages.add(File(filePath));
        showFlash = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        showFlash = false;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(controller!),
          if (showFlash)
            Container(
              color: Colors.white.withOpacity(0.9),
            ),
          if (showReadyMessage)
            Center(
              child: Text(
                'Be Ready!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (isCountingDown || isTakingImages)
            Center(
              child: Text(
                '$countdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 150,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // if (!isTakingImages)
                  Column(
                    children: [
                      Text('Press button to start taking images'),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(250, 40),
                        ),
                        onPressed: isCountingDown ? null : startCountdown,
                        child: Text(
                          'Start',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                // if (capturedImages.isNotEmpty && !isTakingImages)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(250, 40),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadCustomSign(images: capturedImages),
                        ),
                      );
                    },
                    child: Text('Finish'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
