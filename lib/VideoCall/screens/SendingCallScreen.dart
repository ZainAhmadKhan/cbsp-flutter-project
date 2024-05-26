import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/Provider/CheckCallStatusProvider.dart';
import 'package:cbsp_flutter_app/VideoCall/screens/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class SendingCallScreen extends StatefulWidget {
  final String callerId, calleeId;
  final dynamic offer;
  const SendingCallScreen({
    super.key,
    this.offer,
    required this.callerId,
    required this.calleeId,
  });

  @override
  _SendingCallScreenState createState() => _SendingCallScreenState();
}

class _SendingCallScreenState extends State<SendingCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  late MediaStream _localStream;
  bool isMuted = false;
  bool isCameraOff = false;
  final remoteCallerIdTextEditingController = TextEditingController();
  UserDetails? user;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _fetchUserDetails(int.parse(widget.calleeId));
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
  void dispose() {
    _localRenderer.dispose();
    _localStream.dispose();
    super.dispose();
  }

  void _initializeRenderers() async {
    await _localRenderer.initialize();
    _localStream = await _getUserMedia();
    setState(() {
      _localRenderer.srcObject = _localStream;
    });
  }

  Future<MediaStream> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    return await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _localStream.getAudioTracks().forEach((track) {
        track.enabled = !isMuted;
      });
    });
  }

  void _toggleCamera() {
    setState(() {
      isCameraOff = !isCameraOff;
      _localStream.getVideoTracks().forEach((track) {
        track.enabled = !isCameraOff;
      });
    });
  }

  void _switchCamera() {
    _localStream.getVideoTracks().forEach((track) {
      track.switchCamera();
    });
  }

  void _endCall() {
    _localStream.dispose();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final checkCallStatus = Provider.of<checkCallAccepted>(context);
    bool callStatus = checkCallStatus.callStatus;
    if (callStatus) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            callerId: widget.callerId,
            calleeId: widget.calleeId,
            offer: widget.offer,
          ),
        ),
      );
    }
    final bottomBarHeight = 80.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RTCVideoView(
              _localRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: true,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Center(
            child: Column(
              children: [
                SizedBox(height: 200),
                Center(
                    child: Text(
                      '${user?.fname} ${user?.lname}', // Display user's full name
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                SizedBox(height: 8),
                Text(
                  'Calling...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipPath(
        child: BottomAppBar(
          height: bottomBarHeight,
          color: Colors.blueGrey[900],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.switch_camera, color: Colors.white, size: 30),
                onPressed: _switchCamera,
              ),
              IgnorePointer(
                ignoring: isCameraOff,
                child: IconButton(
                  icon: Icon(
                    Icons.videocam_off,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
              ),
              IconButton(
                icon: Icon(
                    isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                    size: 30,
                ),
                onPressed: _toggleMute,
              ),
              CircleAvatar(
                backgroundColor: Colors.red,
                maxRadius: 23,
                child: IconButton(
                  icon: Icon(Icons.call_end, color: Colors.white, size: 30),
                  onPressed: _endCall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
