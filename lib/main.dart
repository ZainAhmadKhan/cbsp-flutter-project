import 'package:cbsp_flutter_app/PreLoginScreens/SplashScreen.dart';
import 'package:cbsp_flutter_app/Provider/CheckCallStatusProvider.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart';
import 'package:cbsp_flutter_app/VideoCall/screens/CapturePicture.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => checkCallAccepted(),
          
        ),
        ChangeNotifierProvider(
          create: (_) => UserIdProvider(0),
        ),
        // Add other providers if necessary
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // home: Dashboard(),
      // home: CameraScreen(),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

