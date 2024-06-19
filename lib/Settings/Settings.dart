import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/LoginScreen/Login.dart';
import 'package:cbsp_flutter_app/Settings/AboutScreen.dart';
import 'package:cbsp_flutter_app/Settings/GeneralScreen.dart';
import 'package:cbsp_flutter_app/Settings/NotificationScreen.dart';
import 'package:cbsp_flutter_app/Settings/ProfileSettingsScreen.dart';
import 'package:cbsp_flutter_app/Settings/TermsAndConditionScreen.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
   final int userId;

  const Settings({Key? key, required this.userId}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  UserDetails? user;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(widget.userId);
  }

  Future<void> _fetchUserDetails(int userId) async {
    try {
      final userDetails = await UserApiHandler.fetchUserDetails(userId);
      setState(() {
        user = userDetails;
      });
    } catch (e) {
      _showErrorMessage("Failed to fetch user details");
    }
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
    String imageUrl = '$Url/profile_pictures/';
    String profileImage = user != null ? imageUrl + user!.profilePicture : 'assets/person.png';
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, 
          ),
          backgroundColor: Colors.grey[300],
          title: const Row(
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user != null
                        ? NetworkImage(profileImage)
                        : AssetImage('assets/person.png') as ImageProvider,
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    '${user?.fname} ${user?.lname}', // Display user's full name
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20.0),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileSettingScreen(userId: widget.userId)),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 20.0,
                      color: Colors.blue,
                    ),
                  ),
                  Text("Edit",style: TextStyle(fontSize: 17),),
                ],
              ),
              
            ),
            Row(
              children: [
                Text(
                  'Disability Type',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                if (user?.disabilityType != null) ...[
                  if (user!.disabilityType.toLowerCase() == 'blind') ...[
                    Icon(Icons.visibility_off, color: Colors.black),
                    SizedBox(width: 5),
                    Text('Blind'),
                  ] else if (user!.disabilityType.toLowerCase() == 'deaf and mute') ...[
                    Icon(Icons.hearing_disabled, color: Colors.black),
                    SizedBox(width: 5),
                    Text('Deaf and Dumb'),
                  ] else ...[
                    Icon(Icons.person, color: Colors.black),
                    SizedBox(width: 5),
                    Text('Normal Person'),
                  ],
                ],
              ],
            ),
            SizedBox(height: 10),
            // Divider
            Divider(
              thickness: 1.0,
              color: Colors.grey,
            ),
            SizedBox(height: 20.0),
            // Buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingButton(label: 'General'),
                  SizedBox(height: 20,),
                  SettingButton(label: 'Notifications'),
                  SizedBox(height: 20,),
                  SettingButton(label: 'Terms and Conditions'),
                  SizedBox(height: 20,),
                  SettingButton(label: 'About Comm Fusion'),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            // Logout Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
              },
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class SettingButton extends StatelessWidget {
  final String label;

  const SettingButton({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Navigate to a new screen based on the label of the button
        if (label == 'General') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GeneralScreen()),
          );
        } else if (label == 'Notifications') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationScreen()),
          );
        } else if (label == 'Terms and Conditions') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TermsAndConditionScreen()),
          );
        } else if (label == 'About Comm Fusion') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AboutScreen()),
          );
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          label,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}