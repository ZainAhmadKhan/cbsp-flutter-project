import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'screens/join_screen.dart';
import 'services/signalling.service.dart';

class VideoCallScreen extends StatefulWidget {
  final int userId;

  const VideoCallScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
   final String websocketUrl = "http://192.168.0.192:5000/";

  // generate callerID of local user
  final String selfCallerID =
      Random().nextInt(9).toString().padLeft(1, '0');

  @override
  Widget build(BuildContext context) {
    // init signalling service
    SignallingService.instance.init(
      websocketUrl: websocketUrl,
      selfCallerID: selfCallerID,
    );

    // return material app
    return MaterialApp(
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(),
      ),
      themeMode: ThemeMode.dark,
      home: JoinScreen(selfCallerId: selfCallerID),
    );
  }
}
