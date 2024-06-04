import 'dart:io';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/ButtonsAndVariables/Buttons.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/CustomWidget/RoundedTextField.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart';
import 'package:cbsp_flutter_app/Settings/Settings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileSettingScreen extends StatefulWidget {
  final int userId;

  const ProfileSettingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String disabilityValue = 'Normal Person';
  File? _selectedImage;
  UserDetails? user;

  @override
  void initState() {
    super.initState();
    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
    int uid = userIdProvider.userId;
    _fetchUserDetails(uid);
  }

  Future<void> _fetchUserDetails(int userId) async {
    try {
      final userDetails = await UserApiHandler.fetchUserDetails(userId);
      setState(() {
        user = userDetails;
        disabilityValue= userDetails.disabilityType;
        statusController.text= userDetails.bioStatus;
        nameController.text=userDetails.fname+" "+userDetails.lname;
      });
    } catch (e) {
      _showErrorMessage("Failed to fetch user details");
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _selectedImage = File(pickedImage.path);
      } else {
        _showErrorMessage('No image selected');
      }
    });
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your name');
      return false;
    }

    if (statusController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your bio status');
      return false;
    }

    if (currentPasswordController.text.isEmpty) {
      _showErrorMessage('Please enter your current password');
      return false;
    }

    if (newPasswordController.text.isEmpty) {
      _showErrorMessage('Please enter a new password');
      return false;
    }

    if (confirmPasswordController.text.isEmpty) {
      _showErrorMessage('Please enter confirm password');
      return false;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showErrorMessage('New Passwords do not match with confirm');
      return false;
    }

    if (currentPasswordController.text != user!.password) {
      _showErrorMessage('Incorrect current Password');
      return false;
    }

    if (nameController.text.trim().split(' ').length < 2) {
      _showErrorMessage('Please enter your full name');
      return false;
    }
    return true;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String profileImage = user != null ? '$Url/profile_pictures/${user!.profilePicture}' : 'assets/person.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Profile Settings',
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _getImage,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (user != null
                            ? NetworkImage(profileImage)
                            : AssetImage('assets/person.png')) as ImageProvider,
                  ),
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
            SizedBox(height: 20),
            RoundedTextField(
              hintText: 'Full Name',
              icon: Icons.person,
              controller: nameController,
            ),
            SizedBox(height: 10),
            RoundedTextField(
              hintText: 'Status',
              icon: Icons.email,
              controller: statusController,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: disabilityValue,
              onChanged: (String? value) {
                setState(() {
                  disabilityValue = value!;
                });
              },
              items: ['Normal Person', 'Blind', 'Deaf and Mute']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Disability',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                focusColor: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            RoundedTextField(
              hintText: 'Current Password',
              icon: Icons.lock,
              obscureText: true,
              controller: currentPasswordController,
            ),
            SizedBox(height: 10),
            RoundedTextField(
              hintText: 'New Password',
              icon: Icons.lock,
              controller: newPasswordController,
            ),
            SizedBox(height: 10),
            RoundedTextField(
              hintText: 'Confirm Password',
              icon: Icons.lock,
              controller: confirmPasswordController,
            ),
            SizedBox(height: 30),
            CustomButton(
              onPressed: () async{
                List<String> names = nameController.text.split(' ');
                String firstName = names.isNotEmpty ? names.first : '';
                String lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
                if (_validateForm()) {
                  final profile = UpdateUserProfile(
                      userId: user!.id, 
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                      newFname: firstName,
                      newLname: lastName,
                      newBioStatus: statusController.text,
                      newDisabilityType: disabilityValue,
                    );

                    
                  bool uploadSuccess = await UserApiHandler.updateUserProfile(profile);
                  if (uploadSuccess) {
                    await UserApiHandler.uploadProfilePicture(user!.id, _selectedImage!);
                    // Profile picture uploaded successfully
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settings(userId: widget.userId)),
                    );
                  } else {
                    showDialog (
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Profile Update Error'),
                        content: Text('Failed to Update Profile.'),
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
                }
              },
              text: 'Update Profile',
            ),
          ],
        ),
      ),
    );
  }
}



