import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:cbsp_flutter_app/APIsHandler/ModelAPI.dart';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/signalling.service.dart';

class CallScreen extends StatefulWidget {
  final String callerId, calleeId;
  final dynamic offer;
  final bool isCaller;
  final VoidCallback onCallEnd;

  const CallScreen({
    super.key,
    this.offer,
    required this.callerId,
    required this.calleeId,
    required this.isCaller,
    required this.onCallEnd,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
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
  String? _callerName;
  String? _calleeName;
  String? _disability;
  final GlobalKey _localRTCVideoRendererKey = GlobalKey();
  Timer? _textClearTimer;
  Timer? _timer;
  late MediaStreamTrack _localVideoTrack;
  String _selectedOption = 'W'; 

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

    _setupPeerConnection();
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

  Future<void> _fetchCallerDetails(int userId) async {
    try {
      final userDetails = await UserApiHandler.fetchUserDetails(userId);
      setState(() {
        _callerName = userDetails.fname;
        _disability= userDetails.disabilityType;
      });
    } catch (e) {
      _showErrorMessage("Failed to fetch user details");
    }
  }

  Future<void> _fetchCalleeDetails(int userId) async {
    try {
      final userDetails = await UserApiHandler.fetchUserDetails(userId);
      setState(() {
        _calleeName = userDetails.fname;
        _disability= userDetails.disabilityType;
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

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _transcribedText = "${result.recognizedWords}";
      _startClearTextTimer();
      if(widget.isCaller)
      {
        socket!.emit('transcribedText', {
        'text': _transcribedText,
        'sender': widget.callerId,
        'receiver': widget.calleeId,
      });
      }
      else
      {
         socket!.emit('transcribedText', {
        'text': _transcribedText,
        'sender': widget.calleeId,
        'receiver': widget.callerId,
      }); 
      }
    });
  }

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

  _setupPeerConnection() async {
    _rtcPeerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    });

    _rtcPeerConnection!.onTrack = (event) {
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      setState(() {});
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn
          ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'}
          : false,
    });

    _localVideoTrack = _localStream!.getVideoTracks().first;

    _localStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _localStream!);
    });

    _localRTCVideoRenderer.srcObject = _localStream;
    setState(() {});

    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await captureFrame();
    });

    if (widget.offer != null) {
      socket!.on("IceCandidate", (data) {
        String candidate = data["iceCandidate"]["candidate"];
        String sdpMid = data["iceCandidate"]["id"];
        int sdpMLineIndex = data["iceCandidate"]["label"];
        _rtcPeerConnection!.addCandidate(RTCIceCandidate(
          candidate,
          sdpMid,
          sdpMLineIndex,
        ));
      });

      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
      );

      RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();
      _rtcPeerConnection!.setLocalDescription(answer);

      socket!.emit("answerCall", {
        "callerId": widget.callerId,
        "sdpAnswer": answer.toMap(),
      });
    } else {
      _rtcPeerConnection!.onIceCandidate =
          (RTCIceCandidate candidate) => rtcIceCadidates.add(candidate);

      socket!.on("callAnswered", (data) async {
        await _rtcPeerConnection!.setRemoteDescription(
          RTCSessionDescription(
            data["sdpAnswer"]["sdp"],
            data["sdpAnswer"]["type"],
          ),
        );

        for (RTCIceCandidate candidate in rtcIceCadidates) {
          socket!.emit("IceCandidate", {
            "calleeId": widget.calleeId,
            "iceCandidate": {
              "id": candidate.sdpMid,
              "label": candidate.sdpMLineIndex,
              "candidate": candidate.candidate
            }
          });
        }
      });

      RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();
      await _rtcPeerConnection!.setLocalDescription(offer);

      socket!.emit('makeCall', {
        "calleeId": widget.calleeId,
        "sdpOffer": offer.toMap(),
      });
    }
  }

  Future<void> captureFrame() async {
  try {
    var buffer = await _localVideoTrack.captureFrame();
    Uint8List pngBytes = buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(pngBytes);
    final Map<String, dynamic>? result;

    if (_selectedOption == "W") {
      result = await ModelAPI.detectAlphabets(imageFile);
    } else {
      result = await ModelAPI.detectPhrases(imageFile);
    }

    if (result != null) {
      setState(() {
        if (_selectedOption == "P") {
         _transcribedText = '${result!['label']}';
        } else {
          _transcribedText = '${result!['class_name']}';
        }
        _startClearTextTimer();
        if(widget.isCaller)
      {
        socket!.emit('transcribedText', {
        'text': _transcribedText,
        'sender': widget.callerId,
        'receiver': widget.calleeId,
      });
      }
      else
      {
         socket!.emit('transcribedText', {
        'text': _transcribedText,
        'sender': widget.calleeId,
        'receiver': widget.callerId,
      }); 
      }
      });
    } else {
      print('Result is null');
    }
  } catch (e) {
    print('Error: $e');
  }
}

  _leaveCall() {



    if(widget.isCaller){
      socket!.emit('endCall', {
      'callerId': widget.callerId,
      'calleeId': widget.calleeId,
    });
    }
    else
    {
      socket!.emit('endCall', {
      'callerId': widget.calleeId,
      'calleeId': widget.callerId,
    });
    }
    
    
    //_stopListening();
    Navigator.pop(context);
    if(!widget.isCaller)
    {widget.onCallEnd();}
  }

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

@override
Widget build(BuildContext context) {

  if (widget.isCaller) {
    _fetchCallerDetails(int.parse(widget.callerId));
  }
   else{
    _fetchCalleeDetails(int.parse(widget.calleeId));
   } 
  

  if (_disability == 'Deaf and Mute') {
    return _deafMuteView();
  } else{
    return _blindNormalView();
  } 
}

Widget _deafMuteView() {
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
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue, // Ensure this matches the `Container` color
                borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
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
                            _selectedOption = value; // Update the selected option
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
                          _selectedOption, // Display the selected option
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        offset: Offset(0, 40), // Adjust position as needed
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
                        onPressed: _leaveCall,
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
            bottom: 100,
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
                      backgroundColor: Colors.green,
                      maxRadius: 23,
                      child: IconButton(
                        icon: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                            color: Colors.white, size: 30),
                        onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      maxRadius: 23,
                      child: IconButton(
                        icon: Icon(Icons.call_end,
                            color: Colors.white, size: 30),
                        onPressed: _leaveCall,
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
