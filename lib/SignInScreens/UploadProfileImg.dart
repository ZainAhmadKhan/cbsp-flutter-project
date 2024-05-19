import 'package:cbsp_flutter_app/CustomWidget/RoundedTextField.dart';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:flutter/material.dart';
import 'package:cbsp_flutter_app/LoginScreen/Login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadProfileImage extends StatefulWidget {
  final String fname;
  final String lname;
  final String email;
  final String password;
  final DateTime dateOfBirth;
  final String disability;
  final String account_status;
  final int online_status;
  final DateTime registration_date;

  const UploadProfileImage({
    required this.fname,
    required this.lname,
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.disability,
    required this.registration_date,
    required this.account_status,
    required this.online_status,
  });

  @override
  _UploadProfileImageState createState() => _UploadProfileImageState();
}

class _UploadProfileImageState extends State<UploadProfileImage> {
  File? _selectedImage; // Path of the selected image
  TextEditingController bioController = TextEditingController();

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
        title: Text('Upload Profile Image'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upload Profile Image',
              style: TextStyle(
                fontSize: 50,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _getImage,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                  image: _selectedImage != null
                      ? DecorationImage(
                          fit: BoxFit.contain,
                          image: FileImage(_selectedImage!),
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.blue,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 30),
            RoundedTextField(
              hintText: 'About',
              icon: Icons.info,
              controller: bioController,
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
              int? userId = await UserApiHandler.signupUser(
                widget.fname,
                widget.lname,
                widget.email,
                widget.password,
                widget.dateOfBirth,
                widget.disability,
                bioController.text,
                widget.account_status,
                widget.online_status,
                widget.registration_date,   
              );

                if (userId != null) {
                  bool uploadSuccess = await UserApiHandler.uploadProfilePicture(userId, _selectedImage!);
                  if (uploadSuccess) {
                    // Profile picture uploaded successfully
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  } else {
                    showDialog (
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Profile Upload Error'),
                        content: Text('Failed to Upload Profile.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  showDialog (
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('SignUp Failure'),
                      content: Text('Failed to Signup.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                minimumSize: Size(250, 50),
              ),
              child: Text('Submit'),
            ),
          ]
        )     
      )
    );
  }
}


