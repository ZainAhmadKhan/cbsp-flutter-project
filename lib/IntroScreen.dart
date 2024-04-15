import 'package:cbsp_flutter_app/LoginScreen/Login.dart';
import 'package:cbsp_flutter_app/SignInScreens/Signup.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30), // for sharp corners
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: -100,
                        left: 90, // Aligning the semicircle at bottom center
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(200), // for the semicircle
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
               
                SizedBox(height: 0), 
                Container(
                  height: 130,
                  width: 130,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 60,
                  width: 140,
                  child: Image.asset(
                    'assets/logo_name2.png',
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 70,
                  width: 250,
                  child: Image.asset(
                    'assets/description.png',
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    minimumSize: Size(250, 50),
                  ),
                  child: Text("Login"),
                ),
                SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SiginupScreen()),
                      );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.black),
                    foregroundColor: Colors.blue,
                    minimumSize: Size(250, 50),
                  ),
                  child: Text("Create an Account", style: TextStyle(color: Colors.blue)),
                ),
              
              ]  
            ),
          ),
        ),
    ); 

  }
}

