import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:cbsp_flutter_app/APIsHandler/ContactsAPI.dart';
import 'package:cbsp_flutter_app/APIsHandler/ModelAPI.dart';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/signalling.service.dart';

class ChatScreen extends StatefulWidget {
  final String caller1Id,caller2Id, calleeId;
  final VoidCallback onCallEnd;

  const ChatScreen({
    super.key,
    required this.caller1Id,
    required this.caller2Id,
    required this.calleeId,
    required this.onCallEnd,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final socket = SignallingService.instance.socket;
  final _localRTCVideoRenderer = RTCVideoRenderer();
  final _remoteRTCVideoRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  RTCPeerConnection? _rtcPeerConnection;
  List<RTCIceCandidate> rtcIceCadidates = [];
  bool isAudioOn = false, isVideoOn = true, isFrontCameraSelected = true;
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String _transcribedText = '';
  UserDetails? _caller1Detail;
  UserDetails? _caller2Detail;
  UserDetails? _calleeDetail;
  Timer? _textClearTimer;
  Timer? _timer;
  late MediaStreamTrack _localVideoTrack;
  String _selectedOption = 'W'; 
  List<UserContact> contacts = [];

  @override
  void initState() {
    super.initState();
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();

    socket!.on("transcribedText", (data) {
      String text = data['text'];
      setState(() {
        _transcribedText = "$text";
        _startClearTextTimer();
      });
    });
    socket!.on("endCall", (data) {
      // _leaveCall();
      Navigator.pop(context);
    });
    _initSpeech();
  }

  void _startClearTextTimer() {
    _textClearTimer?.cancel();
    _textClearTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        _transcribedText = '';
      });
    });
  }

  Future<void> _fetchCaller1Details(int userId) async {
    try {
      final userDetails = await UserApiHandler.fetchUserDetails(userId);
      setState(() {
        _caller1Detail=userDetails;
      });
    } catch (e) {
      _showErrorMessage("Failed to fetch Caller 1 details");
    }
  }

  Future<void> _fetchCaller2Details(int userId) async {
    try {
      final userDetails = await UserApiHandler.fetchUserDetails(userId);
      setState(() {
        _caller1Detail=userDetails;
      });
    } catch (e) {
      _showErrorMessage("Failed to fetch Caller 2 details");
    }
  }
  Future<void> _fetchCalleeDetails(int userId) async {
    try {
      final userDetails = await UserApiHandler.fetchUserDetails(userId);
      setState(() {
        _calleeDetail=userDetails;
      });
    } catch (e) {
      _showErrorMessage("Failed to fetch Caller 2 details");
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

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  // void _startListening() async {
  //   await _speechToText.listen(onResult: _onSpeechResult);
  //   setState(() {});
  // }

  // void _onSpeechResult(SpeechRecognitionResult result) {
  //   setState(() {
  //     _transcribedText = "${result.recognizedWords}";
  //     _startClearTextTimer();
  //     if(widget.isCaller)
  //     {
  //       socket!.emit('transcribedText', {
  //       'text': _transcribedText,
  //       'sender': widget.callerId,
  //       'receiver': widget.calleeId,
  //     });
  //     }
  //     else
  //     {
  //        socket!.emit('transcribedText', {
  //       'text': _transcribedText,
  //       'sender': widget.calleeId,
  //       'receiver': widget.callerId,
  //     }); 
  //     }
  //   });
  // }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5),
      ),
    );
  }

//   Future<void> captureFrame() async {
//   try {
//     var buffer = await _localVideoTrack.captureFrame();
//     Uint8List pngBytes = buffer.asUint8List();

//     final directory = await getApplicationDocumentsDirectory();
//     final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
//     final imageFile = File(imagePath);
//     await imageFile.writeAsBytes(pngBytes);
//     final Map<String, dynamic>? result;

//     if (_selectedOption == "W") {
//       result = await ModelAPI.detectAlphabets(imageFile);
//     } else {
//       result = await ModelAPI.detectPhrases(imageFile);
//     }

//     if (result != null) {
//       setState(() {
//         if (_selectedOption == "P") {
//          _transcribedText = '${result!['label']}';
//         } else {
//           _transcribedText = '${result!['class_name']}';
//         }
//         _startClearTextTimer();
//         if(widget.isCaller)
//       {
//         socket!.emit('transcribedText', {
//         'text': _transcribedText,
//         'sender': widget.callerId,
//         'receiver': widget.calleeId,
//       });
//       }
//       else
//       {
//          socket!.emit('transcribedText', {
//         'text': _transcribedText,
//         'sender': widget.calleeId,
//         'receiver': widget.callerId,
//       }); 
//       }
//       });
//     } else {
//       print('Result is null');
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }

//   _leaveCall() {
//     if(widget.isCaller){
//       socket!.emit('endCall', {
//       'callerId': widget.callerId,
//       'calleeId': widget.calleeId,
//     });
//     }
//     else
//     {
//       socket!.emit('endCall', {
//       'callerId': widget.calleeId,
//       'calleeId': widget.callerId,
//     });
//     }  
//     //_stopListening();
//     Navigator.pop(context);
//     if(!widget.isCaller)
//     {widget.onCallEnd();}
//   }

  _toggleMic() {
    isAudioOn = !isAudioOn;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    setState(() {});
  }

  _toggleCamera() {
    isVideoOn = !isVideoOn;
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
    setState(() {});
  }

  _switchCamera() {
    isFrontCameraSelected = !isFrontCameraSelected;
    _localStream?.getVideoTracks().forEach((track) {
      // ignore: deprecated_member_use
      track.switchCamera();
    });
    setState(() {});
  }
  Future<void> _fetchContacts(int userid) async {
    try {
      await UserApiHandler.updateOnlineStatus(userid,0);
      final fetchedContacts = await ContactApiHandler.getUserContacts(userid);
      setState(() {
        contacts = fetchedContacts;
      });
    } catch (e) {
      _showErrorMessage("No Contacts Load Error!");
    }
  }

@override
Widget build(BuildContext context) {

    _fetchCaller1Details(int.parse(widget.caller1Id));
    _fetchCaller2Details(int.parse(widget.caller2Id));
    _fetchCalleeDetails(int.parse(widget.calleeId));
  

  if (_calleeDetail!.disabilityType == 'Deaf and Mute') {
    return _deafMuteView();
  } else{
    return _blindNormalView();
  } 
}

Widget _deafMuteView() {
  String imageUrl = '$Url/profile_pictures/';
  String Caller1ProfileImage = _caller1Detail != null ? imageUrl + _caller1Detail!.profilePicture : 'assets/person.png';
  String Caller2ProfileImage = _caller2Detail != null ? imageUrl + _caller2Detail!.profilePicture : 'assets/person.png';

  return Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.blueAccent, 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _caller1Detail != null
                            ? NetworkImage(Caller1ProfileImage)
                            : AssetImage('assets/person.png') as ImageProvider,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        '${_caller1Detail?.fname} ${_caller1Detail?.lname}', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            'Transcript Text 1', 
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.greenAccent, 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _caller2Detail != null
                            ? NetworkImage(Caller2ProfileImage)
                            : AssetImage('assets/person.png') as ImageProvider,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        '${_caller2Detail?.fname} ${_caller2Detail?.lname}', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            _transcribedText,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            top: 20,
            child: SizedBox(
              height: 150,
              width: 120,
              child: RTCVideoView(
                _localRTCVideoRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              child: BottomAppBar(
                height: 75,
                color: Colors.blueGrey[900],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      maxRadius: 23,
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            _selectedOption = value; 
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'W',
                              child: Text('W'),
                            ),
                            PopupMenuItem<String>(
                              value: 'P',
                              child: Text('P'),
                            ),
                          ];
                        },
                        child: Text(
                          _selectedOption, 
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        offset: Offset(0, 40), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      maxRadius: 23,
                      child: IconButton(
                        icon: Icon(Icons.call_end,
                            color: Colors.white, size: 30),
                        onPressed:() {
                          // _leaveCall,
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


// View for Blind and Normal
Widget _blindNormalView() {
  return Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          RTCVideoView(
            _remoteRTCVideoRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          Positioned(
            right: 20,
            top: 20,
            child: SizedBox(
              height: 150,
              width: 120,
              child: RTCVideoView(
                _localRTCVideoRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue, 
                borderRadius: BorderRadius.circular(15), 
              ),
              child: Center(
                child: Text(
                  _transcribedText,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.green,
              maxRadius: 30,
              child: IconButton(
                icon: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                    color: Colors.white, size: 40),
                onPressed:(){
                  //  _speechToText.isNotListening ? _startListening : _stopListening
                   },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              child: BottomAppBar(
                height: 75,
                color: Colors.blueGrey[900],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.switch_camera,
                          color: Colors.white, size: 30),
                      onPressed: _switchCamera,
                    ),
                    IconButton(
                      icon: Icon(isVideoOn
                          ? Icons.videocam
                          : Icons.videocam_off,
                          color: Colors.white,
                          size: 30),
                      onPressed: _toggleCamera,
                    ),
                    IconButton(
                      icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off,
                          color: Colors.white, size: 30),
                      onPressed: _toggleMic,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      maxRadius: 23,
                      child: IconButton(
                        icon: Icon(Icons.call_end,
                            color: Colors.white, size: 30),
                        onPressed: (){
                          // _leaveCall

                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  void dispose() {
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    _speechToText.stop();
    _textClearTimer?.cancel();
    super.dispose();
  }
}
