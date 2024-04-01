import 'package:cbsp_flutter_app/Contacts_Screen/Contacts.dart';
import 'package:cbsp_flutter_app/Contacts_Screen/UserProfile.dart';
import 'package:cbsp_flutter_app/Dashboard/Dashboard.dart';
import 'package:cbsp_flutter_app/sign_login_screens/SplashScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // home: Dashboard(),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

