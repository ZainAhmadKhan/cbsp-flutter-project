import 'package:cbsp_flutter_app/CustomWidget/RoundedTextField.dart';
import 'package:cbsp_flutter_app/Dashboard/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadProfileImage extends StatefulWidget {
  const UploadProfileImage({super.key});

  @override
  State<UploadProfileImage> createState() => _UploadProfileImageState();
}

class _UploadProfileImageState extends State<UploadProfileImage> {
   File? _selectedImage; // Path of the selected image

  @override
  void initState() {
    super.initState();
    
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _selectedImage = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        surfaceTintColor: Colors.blue[100],
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.blue,size: 40,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
       body: SingleChildScrollView(
          child: Center(
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'SignUp',
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    'Add your Sing Up details',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
                SizedBox(height: 30,),
                GestureDetector(
                  onTap: _getImage,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                      child: _selectedImage == null
                          ? Icon(
                              Icons.add_a_photo,
                              size: 40,
                            )
                          : null,                       
                    ),
                ),
                SizedBox(height: 30),
                RoundedTextField(
                  hintText: 'About',
                  icon: Icons.info,
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dashboard()),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    minimumSize: Size(250, 50),
                  ),
                  child: Text('Login'),
                ),
               ],
            ),
          ),
          ),
        ),
    );
  }
}