import 'package:audioplayers/audioplayers.dart';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/Provider/CheckCallStatusProvider.dart';
import 'package:cbsp_flutter_app/VideoCall/screens/call_screen.dart';
import 'package:cbsp_flutter_app/VideoCall/services/signalling.service.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


class CallIncomingScreen extends StatefulWidget {
  final String callerId, calleeId;
  final dynamic offer;
  final VoidCallback onCallEnd;
  const CallIncomingScreen({
    super.key,
    this.offer,
    required this.callerId,
    required this.calleeId,
    required this.onCallEnd,
  });

  @override
  State<CallIncomingScreen> createState() => _CallIncomingScreenState();
}

class _CallIncomingScreenState extends State<CallIncomingScreen> {
  bool callAccepted=false;
  UserDetails? user;
  final AudioPlayer _audioPlayer = AudioPlayer();
  dynamic incomingSDPOffer;
  final socket = SignallingService.instance.socket;

  @override
  void initState() {
    super.initState();
    _playRingtone();
    _fetchUserDetails(int.parse(widget.callerId));
    
    SignallingService.instance.socket!.on('endCall', (data) {
      _leaveCall();
    });

  }

  Future<void> _playRingtone() async {
    try{
      await _audioPlayer.setSourceAsset("mp3_files/samsung_galaxy.mp3");
      await _audioPlayer.resume();
    } catch (e) {
      print("Error: $e");
    }
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
        duration: Duration(seconds: 5),
      ),
    );
  }
  void _handleCallEnd() {
    setState(() {
      incomingSDPOffer = null;
    });
  }

  void _stopRingtone() {
    _audioPlayer.stop();
  }
  _leaveCall() {
    socket!.emit('endCall', {
      'callerId': widget.callerId,
      'calleeId': widget.calleeId,
    });
    socket!.on('disconnect', (_) {
      _showMessage("Call Ended");
    });
    widget.onCallEnd();
    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    String imageUrl = '$Url/profile_pictures/';
    String profileImage = user != null ? imageUrl + user!.profilePicture : 'assets/person.png';
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Images/backgroundImage.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2), 
              child: Column(
                children: [
                  SizedBox(height: 100,),
                  Center(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: user != null
                          ? NetworkImage(profileImage)
                          : AssetImage('assets/person.png') as ImageProvider,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      '${user?.fname} ${user?.lname}', // Display user's full name
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Incoming Video Call',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 50,
            child: Draggable(
              feedback: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue,
                child: Icon(Icons.videocam, color: Colors.white, size: 30),
              ),
              childWhenDragging: Container(),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue,
                child: Icon(Icons.videocam, color: Colors.white, size: 30),
              ),
              onDragEnd: (details) {
                if (details.offset.dy < MediaQuery.of(context).size.height / 0.5) {
                  setState(() {
                    callAccepted=true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Provider.of<checkCallAccepted>(context, listen: false).setCallStatus(callAccepted);
                    });
                  });
                  _stopRingtone();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallScreen(
                        callerId: widget.callerId,
                        calleeId: widget.calleeId,
                        isCaller: false,
                        offer: widget.offer,
                        onCallEnd: _handleCallEnd,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Positioned(
            right: 30,
            bottom: 50,
            child: Draggable(
              feedback: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.red,
                child: Icon(Icons.call_end, color: Colors.white, size: 30),
              ),
              childWhenDragging: Container(),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.red,
                child: Icon(Icons.call_end, color: Colors.white, size: 30),
              ),
              onDragEnd: (details) {
                if (details.offset.dy < MediaQuery.of(context).size.height / 0.5) {
                  setState(() {
                    callAccepted=false;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Provider.of<checkCallAccepted>(context, listen: false).setCallStatus(callAccepted);
                    });
                    incomingSDPOffer = null;
                  });
                  _stopRingtone();
                  // _leaveCall();
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
