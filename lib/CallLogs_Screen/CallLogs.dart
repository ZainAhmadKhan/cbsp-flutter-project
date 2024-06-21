import 'package:cbsp_flutter_app/APIsHandler/ParticipantAPI.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/UserIdProvider.dart';

class CallLogs extends StatefulWidget {
  const CallLogs({super.key});

  @override
  State<CallLogs> createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
 List<UserCallDetails> allCallLogs = [];

 @override
  void initState() {
    super.initState();
    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
    int uid = userIdProvider.userId;
    _fetchUserCallLogs(uid);
  }

  Future<void> _fetchUserCallLogs(int userId) async {
    try {
      final userCalls = await ParticipantsApiHandler.fetchAllUserCalls(userId);
      setState(() {
        allCallLogs = userCalls;
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
    String imageUrl = '$Url/profile_pictures/';
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCallLogs.length,
                  itemBuilder: (context, index) {
                    IconData iconData;
                    Color iconColor = Colors.black;

                    switch (allCallLogs[index].isCaller==1) {
                      case true:
                        iconData = Icons.call_made;
                        iconColor = Colors.green;
                        break;
                      case false:
                        iconData = Icons.call_received;
                        iconColor = Colors.red;
                        break;
                      default:
                        iconData = Icons.call;
                        break;
                    }

                    String CallerImageUrl = imageUrl + allCallLogs[index].profilePicture;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(CallerImageUrl), 
                      ),
                      title: Text('${allCallLogs[index].fname} ${allCallLogs[index].lname}'),
                      subtitle: Row(
                        children: [
                          Icon(
                            iconData,
                            color: iconColor,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text('${allCallLogs[index].endTime}'),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 40),
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: allCallLogs[index].onlineStatus == 0 ? Colors.green : Colors.grey,
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
                              int uid = userIdProvider.userId;
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => VideoCallScreen(userId: uid),
                              //   ), // Navigate to VideoCall screen
                              // );
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
              ),
            ],
          ),
        )
      )
    );
  }
}

