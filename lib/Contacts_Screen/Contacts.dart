import 'package:cbsp_flutter_app/APIsHandler/ContactsAPI.dart';
import 'package:cbsp_flutter_app/Contacts_Screen/ShowAllContacts.dart';
import 'package:cbsp_flutter_app/Contacts_Screen/UserProfile.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/VideoCall/VideoCallScreen.dart';
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
  // bool _isLoading = true;
 
  @override
  void initState() {
    super.initState();
    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
    int uid = userIdProvider.userId;
    // int uid=3;
    // _startLoading();
    _loadPinnedMutedAndBlockedContacts();
    _fetchContacts(uid);
  }

  // void _startLoading() async {
  //   await Future.delayed(Duration(seconds: 3));
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }


  Future<void> _fetchContacts(int userid) async {
    try {
      final fetchedContacts = await ContactApiHandler.getUserContacts(userid);
      setState(() {
        contacts = fetchedContacts;
      });
      _reorderContacts();
    } catch (e) {
      _showErrorMessage("No Contacts Load Error!");
    }
  }

  void _reorderContacts() {
    setState(() {
      contacts.sort((a, b) {
        int aId = getUserIdFromProfilePicture(a.profilePicture);
        int bId = getUserIdFromProfilePicture(b.profilePicture);
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

  int getUserIdFromProfilePicture(String profilePicture) {
    final parts = profilePicture.split('_'); 
    final idPart = parts.last.split('.').first; 
    return int.tryParse(idPart) ?? 0; 
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
    final userId = getUserIdFromProfilePicture(contact.profilePicture);
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
    final userId = getUserIdFromProfilePicture(contact.profilePicture);
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
    final userId = getUserIdFromProfilePicture(contact.profilePicture);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: 
      // _isLoading
      //     ? Center(
      //         child: CircularProgressIndicator(),
      //       )
      //     : 
          SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final userId = getUserIdFromProfilePicture(contact.profilePicture);
                    String imageUrl = '$Url/profile_pictures/';
                    String imageName = contact.profilePicture;
                    String profileImage = imageUrl + imageName;
                    bool isPinned = pinnedContacts.contains(getUserIdFromProfilePicture(contact.profilePicture));
                    bool isMuted = mutedContacts.contains(getUserIdFromProfilePicture(contact.profilePicture));
                    bool isBlocked = blockedContacts.contains(getUserIdFromProfilePicture(contact.profilePicture));

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
                              backgroundColor: contact.onlineStatus == 1 ? Colors.green : Colors.grey,
                            ),
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => VideoCallScreen(userId: userId)), // Navigate to VideoCall screen
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
          // int uid=3;
          // print("Floating Uid $uid");
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