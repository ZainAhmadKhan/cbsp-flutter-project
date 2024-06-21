import 'package:camera/camera.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class UploadCustomSign extends StatefulWidget {
  final List<File> images;

  UploadCustomSign({required this.images});

  @override
  _UploadCustomSignState createState() => _UploadCustomSignState();
}

class _UploadCustomSignState extends State<UploadCustomSign> {
  List<File> images = [];
  TextEditingController LabelController = TextEditingController();
  CameraController? _cameraController;
  bool isRetaking = false;
  int? retakeIndex;
  int countdown = 0;
  bool isUploading = false; 
  static const baseUrl = '$Url/testing-CustomSigns';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    images = widget.images;
  }

  @override
  void dispose() {
    images.clear();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.high,
    );
    await _cameraController?.initialize();
    setState(() {});
  }

  void retakeImage(int index) async {
    await initializeCamera();
    setState(() {
      isRetaking = true;
      retakeIndex = index;
    });
  }

  Future<void> startCountdownAndTakePicture() async {
    for (int i = 3; i > 0; i--) {
      setState(() {
        countdown = i;
      });
      await Future.delayed(Duration(seconds: 1));
    }
    setState(() {
      countdown = 0;
    });
    await takePicture();
  }

  Future<void> takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    final filePath = join(directory.path, '${DateTime.now()}.png');
    if (_cameraController!.value.isTakingPicture) {
      return;
    }
    try {
      final XFile picture = await _cameraController!.takePicture();
      final File imageFile = File(picture.path);
      await imageFile.copy(filePath);
      setState(() {
        images[retakeIndex!] = File(filePath);
        isRetaking = false;
        _cameraController?.dispose();
        _cameraController = null;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadImagesAndTrain(String user, String label, List<File> images) async {
    // Validate label field
    if (label.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in the label field.'),
      ));
      return;
    }

    setState(() {
      isUploading = true; // Set uploading flag to true
    });

    // Call API to upload images and train
    var uri = Uri.parse('$baseUrl/train/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['user'] = user;
    request.fields['label'] = label;

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path));
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Training successful
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Images uploaded and model trained successfully.'),
        ));
        print('Training successful');
      } else {
        // Training failed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to train model. Please try again.'),
        ));
        print('Training failed');
      }
    } catch (e) {
      // Exception occurred
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
      print('Error: $e');
    } finally {
      setState(() {
        isUploading = false; // Set uploading flag to false
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.length + images.length <= 5) {
      setState(() {
        images.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only select up to 5 images.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Custom Sign'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Expanded(
                          child: Image.file(images[index]),
                        ),
                        ElevatedButton(
                          onPressed: () => retakeImage(index),
                          child: Text('Retake Image ${index + 1}'),
                        ),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Pick Images from Gallery'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: LabelController,
                  decoration: InputDecoration(labelText: 'Label for all Images'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(250, 40),
                  ),
                  onPressed: () {
                    // Get user ID
                    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
                    int uid = userIdProvider.userId;
                    uploadImagesAndTrain(uid.toString(), LabelController.text, images);
                  },
                  child: Text('Upload'),
                ),
              ),
            ],
          ),
          if (isRetaking && _cameraController != null && _cameraController!.value.isInitialized)
            Positioned.fill(
              child: Stack(
                children: [
                  CameraPreview(_cameraController!),
                  if (countdown > 0)
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: startCountdownAndTakePicture,
                      child: Text('Click'),
                    ),
                  ),
                ],
              ),
            ),
          if (isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20.0),
                    Text(
                      'Please wait, your custom signs are training on AI model...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
