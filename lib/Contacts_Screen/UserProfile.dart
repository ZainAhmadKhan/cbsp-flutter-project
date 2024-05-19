import 'package:cbsp_flutter_app/APIsHandler/ParticipantSAPI.dart';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/VideoCall/VideoCallScreen.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  final int userId;

  const UserProfile({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  UserDetails? user;
  List<CallDetails> callDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(widget.userId);
    _fetchUserCalls(widget.userId);
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

  Future<void> _fetchUserCalls(int userId) async {
    try {
      final userCalls = await ParticipantsApiHandler.fetchUserCalls(userId);
      setState(() {
        callDetails = userCalls;
      });
    } catch (e) {
      _showErrorMessage("Failed to fetch user calls");
      print('Error fetching user calls: $e');
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
  Widget build(BuildContext context) {
    String imageUrl = 'http://192.168.43.55:8000/profile_pictures/';
    String profileImage = user != null ? imageUrl + user!.profilePicture : 'assets/person.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user != null
                        ? NetworkImage(profileImage)
                        : AssetImage('assets/person.png') as ImageProvider,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    '${user?.fname} ${user?.lname}', // Display user's full name
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    user?.bioStatus ?? '', // Display user's bio
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                  height: 40,
                  indent: 20,
                  endIndent: 20,
                ),
                Row(
                  children: [
                    Text(
                      'Disability Type',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    if (user?.disabilityType != null) ...[
                      if (user!.disabilityType.toLowerCase() == 'blind') ...[
                        Icon(Icons.visibility_off, color: Colors.black),
                        SizedBox(width: 5),
                        Text('Blind'),
                      ] else if (user!.disabilityType.toLowerCase() == 'deaf and dumb') ...[
                        Icon(Icons.hearing_disabled, color: Colors.black),
                        SizedBox(width: 5),
                        Text('Deaf and Dumb'),
                      ] else ...[
                        Icon(Icons.person, color: Colors.black),
                        SizedBox(width: 5),
                        Text('Normal Person'),
                      ],
                    ],
                  ],
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: callDetails.length,
                  itemBuilder: (context, index) {
                    IconData iconData;
                    Color iconColor = Colors.black;

                    switch (callDetails[index].isCaller) {
                      case true:
                        iconData = Icons.call_made;
                        iconColor = Colors.green;
                        break;
                      case false:
                        iconData = Icons.call_received;
                        iconColor = Colors.green;
                        break;
                      default:
                        iconData = Icons.call;
                        break;
                    }

                    String participantImageUrl = imageUrl + callDetails[index].profilePicture;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(participantImageUrl), // Participant's image
                      ),
                      title: Text('${callDetails[index].otherParticipantFname} ${callDetails[index].otherParticipantLname}'),
                      subtitle: Row(
                        children: [
                          Icon(
                            iconData,
                            color: iconColor,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text('${callDetails[index].startTime}'),
                        ],
                      ),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 10),
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: callDetails[index].onlineStatus==1 ? Colors.green : Colors.grey,
                            ),
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => VideoCallScreen(userId: widget.userId)), // Navigate to VideoCall screen
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
                    );
                  },
                ),
              ],
            ),
    );
  }
}