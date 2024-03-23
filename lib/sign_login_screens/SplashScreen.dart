import 'package:cbsp_flutter_app/sign_login_screens/IntroScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      // Navigate to the login screen after 3 seconds
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => IntroScreen()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(      
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container( height: 150, 
            width: 150,
            child: Image.asset('assets/logo.png',
            fit: BoxFit.fill,)
            ),
            Container( height: 60, 
            width: 200,
            child: Image.asset('assets/logo_name.png',
            fit: BoxFit.fill,)
            )

          ],
        ),
      ),
    );
  }
}
