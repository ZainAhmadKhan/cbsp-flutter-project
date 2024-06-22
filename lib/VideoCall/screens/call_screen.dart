import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:cbsp_flutter_app/APIsHandler/ContactsAPI.dart';
import 'package:cbsp_flutter_app/APIsHandler/ModelAPI.dart';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart';
import 'package:cbsp_flutter_app/VideoCall/screens/Chat_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/signalling.service.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  Timer? _textClearTimer;
  Timer? _timer;
  late MediaStreamTrack _localVideoTrack;
  String _selectedOption = 'W'; 
  List<UserContact> contacts = [];
  final TextToSpeechService _textToSpeechService = TextToSpeechService();
  Timer? _ImageTimer;
  String? _currentAsset;
  dynamic incomingSDPOffer;

  @override
  void initState() {
    super.initState();
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();

    socket!.on("transcribedText", (data) {
      String text = data['text'];
      setState(() {
        _transcribedText = "$text";
        if(_disability=="Blind")
        {
          _textToSpeechService.speak(_transcribedText);
        }
        final assetName;
        if(_selectedOption=='P')
        {
          assetName = '${_transcribedText.toLowerCase().replaceAll(' ', '')}'; 
        }
        else
        {
          assetName = '${_transcribedText}-ASL';
        } 
        String gifPath = 'assets/gestures/$assetName.gif';
        String pngPath = 'assets/gestures/$assetName.png';
        String jpgPath = 'assets/gestures/$assetName.png';
        if (AssetImage(gifPath) != null) {
          _showImage(gifPath);
        } 
        else if (AssetImage(pngPath) != null) {
          _showImage(pngPath);
        }
        else if (AssetImage(jpgPath) != null) {
          _showImage(pngPath);
        }
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
        _textToSpeechService.stop();
      });
    });
  }

  void _showImage(String assetName) {
    setState(() {
      _currentAsset = assetName;
    });

    _timer?.cancel();
    _timer = Timer(Duration(seconds: 3), () {
      setState(() {
        _currentAsset = null;
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
    void _handleCallEnd() {
      setState(() {
        incomingSDPOffer = null;
      });
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
            bottom: 150,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              child: _currentAsset != null 
                ? Image.asset(_currentAsset!)
                : SizedBox.shrink(), // A placeholder widget when _currentAsset is null
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
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      maxRadius: 23,
                      child: IconButton(
                        icon: const Icon(Icons.person_add,
                            color: Colors.white, size: 30),
                        onPressed: (){
                          _showUserDialog();
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
                onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
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
                        onPressed: _leaveCall,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      maxRadius: 23,
                      child: IconButton(
                        icon: const Icon(Icons.person_add,
                            color: Colors.white, size: 30),
                        onPressed: (){
                          _showUserDialog();
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

void _showUserDialog() {
  final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
  int uid = userIdProvider.userId;
  _fetchContacts(uid);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          height: 400, // Adjust the height as needed
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Add Friend in a GroupChat',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contacts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == contacts.length) {
                      return SizedBox(height: 80);
                    }
                    final contact = contacts[index];
                    final userId = contact.id;

                    if (userId == int.parse(widget.callerId) || userId == int.parse(widget.calleeId)) {
                      return Container(); 
                    }
                    String imageUrl = '$Url/profile_pictures/';
                    String imageName = contact.profilePicture;
                    String profileImage = imageUrl + imageName;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(profileImage), 
                      ),
                      title: Text('${contact.fname} ${contact.lname}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 10),
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: contact.onlineStatus == 0 ? Colors.green : Colors.grey,
                          ),
                          SizedBox(width: 20),
                          IconButton(
                            icon: Icon(
                              Icons.group_add,
                              color: contact.onlineStatus == 0 ? Colors.green : Colors.grey.withOpacity(0.5),
                              size: 32,
                            ),
                            onPressed: contact.onlineStatus == 0 
                              ? () async{
                                // dynamic offer;
                                RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();
                                await _rtcPeerConnection!.setLocalDescription(offer);
                                socket!.emit('makeChatCall', {
                                  "calleeId": contact.id.toString(),
                                  "caller1Id": widget.calleeId,
                                  "caller2Id": widget.callerId,
                                  "sdpOffer": offer.toMap(),
                                });
                                Navigator.pop(context);
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => ChatScreen(
                                  //     caller1Id: widget.calleeId,
                                  //     caller2Id: widget.callerId,
                                  //     calleeId: contact.id.toString(),
                                  //     offer: offer,
                                  //     onCallEnd: _handleCallEnd,
                                  //   )),
                                  // );
                                }
                              : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
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

class TextToSpeechService {
  final FlutterTts flutterTts;

  TextToSpeechService() : flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US"); // Set the language (e.g., "en-US" for English)
    await flutterTts.setSpeechRate(0.5); // Set the speech rate (0.0 to 1.0)
    await flutterTts.setVolume(1.0); // Set the volume (0.0 to 1.0)
    await flutterTts.setPitch(1.0); // Set the pitch (0.5 to 2.0)

    await flutterTts.speak(text); // Convert the text to speech
  }

  Future<void> stop() async {
    await flutterTts.stop(); // Stop speaking
  }
}