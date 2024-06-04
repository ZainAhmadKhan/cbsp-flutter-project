import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/signalling.service.dart';


class CallScreen extends StatefulWidget {
  final String callerId, calleeId;
  final dynamic offer;
  final VoidCallback onCallEnd;

  const CallScreen({
    super.key,
    this.offer,
    required this.callerId,
    required this.calleeId,
    required this.onCallEnd,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // socket instance
  final socket = SignallingService.instance.socket;

  // videoRenderer for localPeer
  final _localRTCVideoRenderer = RTCVideoRenderer();

  // videoRenderer for remotePeer
  final _remoteRTCVideoRenderer = RTCVideoRenderer();

  // mediaStream for localPeer
  MediaStream? _localStream;

  // RTC peer connection
  RTCPeerConnection? _rtcPeerConnection;

  // list of rtcCandidates to be sent over signalling
  List<RTCIceCandidate> rtcIceCadidates = [];

  // media status
  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;

  // Speech to text
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String _transcribedText = '';
  String? _callerName;
  String? _calleeName;
  final GlobalKey _localRTCVideoRendererKey = GlobalKey();
  Timer? _textClearTimer;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchCallerDetails(int.parse(widget.callerId));
    _fetchCalleeDetails(int.parse(widget.calleeId));
    // initializing renderers
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();

    socket!.on("transcribedText", (data) {
      String text = data['text'];

      // Handle the transcribed text
      setState(() {
        _transcribedText = "$text";
        _startClearTextTimer();
      });
    });

    // setup Peer Connection
    _setupPeerConnection();

    // Listen for 'endCall' event to end the call
    socket!.on('endCall', (data) {
      _leaveCall();
    });

    // Initialize speech recognition
    _initSpeech();
  }

  void _startClearTextTimer() {
    // Cancel the previous timer if it exists
    _textClearTimer?.cancel();
    _textClearTimer = Timer(Duration(seconds: 10), () {
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
      // Send transcribed text to the remote peer
      socket!.emit('transcribedText', {
        'text': _transcribedText,
        'sender': widget.callerId,
        'receiver': widget.calleeId,
      });
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
    // create peer connection
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

    // listen for remotePeer mediaTrack event
    _rtcPeerConnection!.onTrack = (event) {
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      setState(() {});
    };

    // get localStream
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn
          ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'}
          : false,
    });

    // add mediaTrack to peerConnection
    _localStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _localStream!);
    });

    // set source for local video renderer
    _localRTCVideoRenderer.srcObject = _localStream;
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await captureFrame();
    });
    setState(() {});

    // for Incoming call
    if (widget.offer != null) {
      // listen for Remote IceCandidate
      socket!.on("IceCandidate", (data) {
        String candidate = data["iceCandidate"]["candidate"];
        String sdpMid = data["iceCandidate"]["id"];
        int sdpMLineIndex = data["iceCandidate"]["label"];

        // add iceCandidate
        _rtcPeerConnection!.addCandidate(RTCIceCandidate(
          candidate,
          sdpMid,
          sdpMLineIndex,
        ));
      });

      // set SDP offer as remoteDescription for peerConnection
      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
      );

      // create SDP answer
      RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();

      // set SDP answer as localDescription for peerConnection
      _rtcPeerConnection!.setLocalDescription(answer);

      // send SDP answer to remote peer over signalling
      socket!.emit("answerCall", {
        "callerId": widget.callerId,
        "sdpAnswer": answer.toMap(),
      });
    }
    // for Outgoing Call
    else {
      // listen for local iceCandidate and add it to the list of IceCandidate
      _rtcPeerConnection!.onIceCandidate =
          (RTCIceCandidate candidate) => rtcIceCadidates.add(candidate);

      // when call is accepted by remote peer
      socket!.on("callAnswered", (data) async {
        // set SDP answer as remoteDescription for peerConnection
        await _rtcPeerConnection!.setRemoteDescription(
          RTCSessionDescription(
            data["sdpAnswer"]["sdp"],
            data["sdpAnswer"]["type"],
          ),
        );

        // send iceCandidate generated to remote peer over signalling
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

      // create SDP Offer
      RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();

      // set SDP offer as localDescription for peerConnection
      await _rtcPeerConnection!.setLocalDescription(offer);

      // make a call to remote peer over signalling
      socket!.emit('makeCall', {
        "calleeId": widget.calleeId,
        "sdpOffer": offer.toMap(),
      });
    }
  }

  Future<void> captureFrame() async {
    try {
      RenderRepaintBoundary boundary = _localRTCVideoRendererKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // Save the captured frame to the gallery
      await GallerySaver.saveImage(imageFile.path);
      print('Frame saved to gallery: $imagePath');
    } catch (e) {
      print('Error capturing frame: $e');
    }
  }

  _leaveCall() {
    // Emit 'endCall' event to signal the end of the call
    socket!.emit('endCall', {
      'callerId': widget.callerId,
      'calleeId': widget.calleeId,
    });
    _stopListening();
    Navigator.pop(context);
    widget.onCallEnd();
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
                  key: _localRTCVideoRendererKey,
                ),
              ),
            ),
            Positioned(
              bottom: 100, 
              left: 20,
              right: 20,
              child: Container(
                color: Colors.black54,
                padding: EdgeInsets.all(10),
                child: Text(
                  _transcribedText,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                // clipper: BottomNavBarClipper(),
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
    // Dispose of resources and cancel ongoing operations
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();

    // Dispose of the speech recognition
    _speechToText.stop();

    // Cancel the text clear timer if it exists
    _textClearTimer?.cancel();

    super.dispose();
  }
}
