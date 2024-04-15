import 'package:cbsp_flutter_app/Settings/AboutScreen.dart';
import 'package:cbsp_flutter_app/Settings/GeneralScreen.dart';
import 'package:cbsp_flutter_app/Settings/NotificationScreen.dart';
import 'package:cbsp_flutter_app/Settings/TermsAndConditionScreen.dart';
import 'package:cbsp_flutter_app/sign_login_screens/Login.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            // Profile Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25.0,
                    backgroundImage: AssetImage('assets/person.png'), // Replace with actual image URL
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    'Zain Ahmad',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(width: 120.0),
                  Text(
                    '>',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            ),
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
                  SizedBox(height: 10,),
                  SettingButton(label: 'Notifications'),
                  SizedBox(height: 10,),
                  SettingButton(label: 'Terms and Conditions'),
                  SizedBox(height: 10,),
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
                primary: Colors.white,
                onPrimary: Colors.black,
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