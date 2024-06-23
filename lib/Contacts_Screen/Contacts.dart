import 'package:audioplayers/audioplayers.dart';
import 'package:cbsp_flutter_app/APIsHandler/ContactsAPI.dart';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/Contacts_Screen/ShowAllContacts.dart';
import 'package:cbsp_flutter_app/Contacts_Screen/UserProfile.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/VideoCall/screens/CallIncomingScreen.dart';
import 'package:cbsp_flutter_app/VideoCall/screens/Chat_Screen.dart';
import 'package:cbsp_flutter_app/VideoCall/screens/call_screen.dart';
import 'package:cbsp_flutter_app/VideoCall/services/signalling.service.dart';
import 'package:flutter/material.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart'; 
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contacts extends StatefulWidget {
  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<UserContact> contacts = []; 
  int uid = 0;
  Set<int> pinnedContacts = {};
  Set<int> mutedContacts = {};
  Set<int> blockedContacts = {};
  dynamic incomingSDPOffer;
  dynamic incomingChatSDPOffer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final socket = SignallingService.instance.socket;
 
  @override
  void initState() {
    super.initState(); 
    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
    int uid = userIdProvider.userId;
    _fetchContacts(uid);
    _loadPinnedMutedAndBlockedContacts();
    _incomingCallListener();
    _incomingCallChatListener();
    _callEndListener();
  }

  void _incomingCallListener() {
    SignallingService.instance.socket!.on("newCall", (data) {
      if (mounted) {
        setState(() {
          incomingSDPOffer = data;
          _playRingtone();
        });
      }
    });
  }

  void _incomingCallChatListener() {
    SignallingService.instance.socket!.on("newChatCall", (data) {
      if (mounted) {
        setState(() {
          incomingChatSDPOffer = data;
          _playRingtone();
        });
      }
    });
  }
  void _callEndListener() {
    SignallingService.instance.socket!.on('endCall', (data) {
      if (mounted) {
        setState(() {
          incomingSDPOffer = null;
          socket!.on('disconnect', (_) {
            _showMessage("Call Ended");
          });
          _stopRingtone();
        });
      }
    });
  }
  void _handleCallEnd() {
    setState(() {
      incomingSDPOffer = null;
    });
  }

  Future<void> _fetchContacts(int userid) async {
    try {
      await UserApiHandler.updateOnlineStatus(userid,0);
      final fetchedContacts = await ContactApiHandler.getUserContacts(userid);
      setState(() {
        contacts = fetchedContacts;
      });
      _reorderContacts();
    } catch (e) {
      _showErrorMessage("No Contacts Load Error!");
    }
  }

  Future<void> _playRingtone() async {
    try{
      await _audioPlayer.setSourceAsset("mp3_files/samsung_galaxy.mp3");
      await _audioPlayer.resume();
    } catch (e) {
      print("Error: $e");
    }
  }
  void _stopRingtone() {
    _audioPlayer.stop();
  }

  void _reorderContacts() {
    setState(() {
      contacts.sort((a, b) {
        int aId = a.id;
        int bId = b.id;
        if (pinnedContacts.contains(aId) && !pinnedContacts.contains(bId)) {
          return -1;
        } else if (!pinnedContacts.contains(aId) && pinnedContacts.contains(bId)) {
          return 1;
        } else {
          return 0;
        }
      });
    });
  }
 
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showOptions(BuildContext context, UserContact contact) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(10),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.push_pin),
                onPressed: () {
                  _togglePinContact(contact);
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.volume_off),
                onPressed: () {
                  _toggleMuteContact(contact);
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.block),
                onPressed: () {
                  _toggleBlockContact(contact);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _togglePinContact(UserContact contact) {
    final userId = contact.id;
    setState(() {
      if (pinnedContacts.contains(userId)) {
        pinnedContacts.remove(userId);
      } else {
        pinnedContacts.add(userId);
      }
    });
    _savePinnedContacts();
    _reorderContacts();
  }

  void _toggleMuteContact(UserContact contact) {
    final userId = contact.id;
    setState(() {
      if (mutedContacts.contains(userId)) {
        mutedContacts.remove(userId);
      } else {
        mutedContacts.add(userId);
      }
    });
    _saveMutedContacts();
  }

  void _toggleBlockContact(UserContact contact) {
    final userId = contact.id;
    setState(() {
      if (blockedContacts.contains(userId)) {
        blockedContacts.remove(userId);
      } else {
        blockedContacts.add(userId);
      }
    });
    _saveBlockedContacts();
  }

  Future<void> _loadPinnedMutedAndBlockedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pinnedContacts = prefs.getStringList('pinnedContacts')?.map((e) => int.parse(e)).toSet() ?? {};
      mutedContacts = prefs.getStringList('mutedContacts')?.map((e) => int.parse(e)).toSet() ?? {};
      blockedContacts = prefs.getStringList('blockedContacts')?.map((e) => int.parse(e)).toSet() ?? {};
    });
  }

  Future<void> _savePinnedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pinnedContacts', pinnedContacts.map((e) => e.toString()).toList());
  }

  Future<void> _saveMutedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mutedContacts', mutedContacts.map((e) => e.toString()).toList());
  }

  Future<void> _saveBlockedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blockedContacts', blockedContacts.map((e) => e.toString()).toList());
  }
  _sendCall({
    required String callerId,
    required String calleeId,
    dynamic offer,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callerId: callerId,
          calleeId: calleeId,
          isCaller: true,
          offer: offer,
          onCallEnd: _handleCallEnd,
        ),
      ),
    );
  }
  _receiveCall({
    required String callerId,
    required String calleeId,
    dynamic offer,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callerId: callerId,
          calleeId: calleeId,
          isCaller: false,
          offer: offer,
          onCallEnd: _handleCallEnd,
        ),
      ),
    );
  }
  _receiveChatCall({
    required String caller1Id,
    required String caller2Id,
    required String calleeId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          caller1Id: caller1Id,
          caller2Id: caller2Id,
          calleeId: calleeId,
          onCallEnd: _handleCallEnd,
        ),
      ),
    );
  }
  _leaveCall() {
    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
    int uid = userIdProvider.userId;
    socket!.emit('endCall', {
      'callerId': incomingSDPOffer["callerId"],
      'calleeId': uid.toString(),
    });
    socket!.on('disconnect', (_) {
      _showMessage("Call Ended");
    });
    _stopRingtone();
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // Incoming Call UI
              if (incomingSDPOffer != null)
                ListTile(
                  title: Text(
                    "Incoming Call from ${incomingSDPOffer["callerId"]}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call_end),
                        color: Colors.redAccent,
                        onPressed: () {
                          _stopRingtone();
                          setState(() => incomingSDPOffer = null);
                          // Stop ringtone when call is declined
                          _leaveCall;
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.call),
                        color: Colors.greenAccent,
                        onPressed: () {
                          _stopRingtone();
                          final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
                          int uid = userIdProvider.userId;
                          _receiveCall(
                            callerId: incomingSDPOffer["callerId"]!,
                            calleeId: uid.toString(),
                            offer: incomingSDPOffer["sdpOffer"],
                          );
                        },
                      )
                    ],
                  ),
                  onTap: ()
                  {
                    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
                    int uid = userIdProvider.userId;
                    _stopRingtone();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallIncomingScreen(
                          callerId: incomingSDPOffer["callerId"]!,
                          calleeId: uid.toString(),
                          offer: incomingSDPOffer["sdpOffer"],
                          onCallEnd: _handleCallEnd,
                        ),
                      ),
                    );
                  },
                ),
                if (incomingChatSDPOffer != null)
                ListTile(
                  title: Text(
                    "Incoming Call from ${incomingChatSDPOffer["caller1Id"]} and ${incomingChatSDPOffer["caller2Id"]}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call_end),
                        color: Colors.redAccent,
                        onPressed: () {
                          _stopRingtone();
                          setState(() => incomingChatSDPOffer = null);
                          // _leaveCall;
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.call),
                        color: Colors.greenAccent,
                        onPressed: () {
                          _stopRingtone();
                          final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
                          int uid = userIdProvider.userId;
                           Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChatScreen(
                                caller1Id: incomingChatSDPOffer["caller1Id"],
                                caller2Id: incomingChatSDPOffer["caller2Id"],
                                calleeId: uid.toString(),
                                onCallEnd: _handleCallEnd,
                              )),
                            );
                          // _receiveChatCall(
                          //   caller1Id: incomingChatSDPOffer["caller1Id"]!,
                          //   caller2Id: incomingChatSDPOffer["caller2Id"]!,
                          //   calleeId: uid.toString(),
                          //   offer: incomingSDPOffer["sdpOffer"],
                          // );
                        },
                      )
                    ],
                  ),
                  // onTap: ()
                  // {
                  //   final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
                  //   int uid = userIdProvider.userId;
                  //   _stopRingtone();
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (_) => CallIncomingScreen(
                  //         callerId: incomingSDPOffer["callerId"]!,
                  //         calleeId: uid.toString(),
                  //         offer: incomingSDPOffer["sdpOffer"],
                  //         onCallEnd: _handleCallEnd,
                  //       ),
                  //     ),
                  //   );
                  // },
                ),
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contacts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == contacts.length) {
                      return SizedBox(height: 80);
                    }
                  final contact = contacts[index];
                  final userId = contact.id;
                  String imageUrl = '$Url/profile_pictures/';
                  String imageName = contact.profilePicture;
                  String profileImage = imageUrl + imageName;
                  bool isPinned = pinnedContacts.contains(userId);
                  bool isMuted = mutedContacts.contains(userId);
                  bool isBlocked = blockedContacts.contains(userId);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserProfile(userId: userId)), // Navigate to UserProfile screen
                      );
                    },
                    onLongPress: () => _showOptions(context, contact),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(profileImage), 
                      ),
                      title: Text('${contact.fname} ${contact.lname}'),
                      subtitle: Text(contact.bioStatus),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPinned) Icon(Icons.push_pin, size: 20, color: Colors.grey),
                          if (isMuted) Icon(Icons.volume_off, size: 20, color: Colors.grey),
                          if (isBlocked) Icon(Icons.block, size: 20, color: Colors.grey),
                          SizedBox(width: 10),
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: contact.onlineStatus == 0 ? Colors.green : Colors.grey,
                          ),
                          SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
                              int uid = userIdProvider.userId;
                              _sendCall(
                                callerId: uid.toString(),
                                calleeId: contact.id.toString(),
                              );
                            },
                            child: Icon(
                              Icons.videocam,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],      
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
        int uid = userIdProvider.userId;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShowAllContacts(userId: uid)),
        );
      },
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Icon(Icons.add),
    ),
  );
}
}
