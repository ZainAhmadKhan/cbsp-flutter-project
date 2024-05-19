import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  final int userId;

  const VideoCallScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Call with User ID: ${widget.userId}"),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Video call with User ID: ${widget.userId}',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
