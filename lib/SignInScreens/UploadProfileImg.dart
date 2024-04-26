// import 'package:cbsp_flutter_app/LoginScreen/Login.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class UploadProfileImage extends StatefulWidget {
//   const UploadProfileImage({Key? key}) : super(key: key);

//   @override
//   _UploadProfileImageState createState() => _UploadProfileImageState();
// }

// class _UploadProfileImageState extends State<UploadProfileImage> {
//   File? _selectedImage; // Path of the selected image

//   Future<void> _getImage() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.gallery);

//     setState(() {
//       if (pickedImage != null) {
//         _selectedImage = File(pickedImage.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Upload Profile Image'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   'SignUp',
//                   style: TextStyle(
//                     fontSize: 50,
//                     color: Colors.blue,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'Add your Sign Up details',
//                   style: TextStyle(color: Colors.black, fontSize: 15),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 30),
//                 GestureDetector(
//                   onTap: _getImage,
//                   child: Container(
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.blue, width: 2),
                      
//                       image: _selectedImage != null
//                           ? DecorationImage(
//                               fit: BoxFit.contain,
//                               image: FileImage(_selectedImage!),
//                             )
//                           : null,
//                     ),
//                     child: _selectedImage == null
//                         ? Icon(
//                             Icons.add_a_photo,
//                             size: 40,
//                             color: Colors.blue,
//                           )
//                         : null,
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 TextField(
//                   decoration: InputDecoration(
//                     hintText: 'About',
//                     icon: Icon(Icons.info),
//                     border: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.blue, width: 2),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 50),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => LoginScreen()
//                           ),
//                         );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     primary: Colors.blue,
//                     onPrimary: Colors.white,
//                     minimumSize: Size(250, 50),
//                   ),
//                   child: Text('Submit'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cbsp_flutter_app/LoginScreen/Login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadProfileImage extends StatefulWidget {
  final String username;
  final String name;
  final String email;
  final String password;
  final DateTime dateOfBirth;
  final String disability;

  const UploadProfileImage({
    required this.username,
    required this.name,
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.disability,
  });

  @override
  _UploadProfileImageState createState() => _UploadProfileImageState();
}

class _UploadProfileImageState extends State<UploadProfileImage> {
  File? _selectedImage; // Path of the selected image

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
            TextField(
              decoration: InputDecoration(
                hintText: 'About',
                icon: Icon(Icons.info),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Call API to signup user with the provided data
                // Navigate back to login screen after successful signup
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                minimumSize: Size(250, 50),
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}


