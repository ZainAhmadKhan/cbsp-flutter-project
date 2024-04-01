import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final List<CallHistory> callHistory = [
  CallHistory(
    name: "John Doe",
    isOnline: true,
    type: "Incoming",
    date: "March 14,",
    time: "10:10 AM",
  ),
  CallHistory(
    name: "John Doe",
    isOnline: true,
    type: "Outgoing",
    date: "April 5,",
    time: "11:30 AM",
  ),
  CallHistory(
    name: "John Doe",
    isOnline: true,
    type: "Missed",
    date: "May 21,",
    time: "1:45 PM",
  ),
  CallHistory(
    name: "John Doe",
    isOnline: true,
    type: "Incoming",
    date: "June 9,",
    time: "3:20 PM",
  ),
  CallHistory(
    name: "John Doe",
    isOnline: true,
    type: "Outgoing",
    date: "July 17,",
    time: "5:00 PM",
  ),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Row(
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/person.png'), // Replace with your image path
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'John Doe', 
              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              'Software Engineer', // Replace with the user's about
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
          Text(
            'Disability Type',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Display users with disabilities
          ListView.builder(
              shrinkWrap: true,
              itemCount: callHistory.length,
              itemBuilder: (context, index) {
                IconData iconData;
                Color iconColor = Colors.black;

                switch (callHistory[index].type) {
                  case 'Incoming':
                    iconData = Icons.call_received;
                    iconColor = Colors.green;
                    break;
                  case 'Outgoing':
                    iconData = Icons.call_made;
                    iconColor = Colors.green;
                    break;
                  case 'Missed':
                    iconData = Icons.call_missed;
                    iconColor = Colors.red;
                    break;
                  default:
                    iconData = Icons.call;
                    break;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/person.png'), // Dummy image
                  ),
                  title: Text(callHistory[index].name),
                  subtitle: Row(
                    children: [
                      Icon(
                        iconData,
                        color: iconColor,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text(callHistory[index].date + " " + callHistory[index].time),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 50,),
                              CircleAvatar(
                                radius: 5,
                                backgroundColor: callHistory[index].isOnline ? Colors.green : Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 10), // Adjust spacing as needed
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

class UserHistory {
  final String name;
  final String about;
  final bool isOnline;
  final String lastSeen;

  UserHistory({
    required this.name,
    required this.about,
    required this.isOnline,
    required this.lastSeen,
  });
}
class CallHistory {
  final String name;
  final bool isOnline;
  final String type;
  final String date;
  final String time;

  CallHistory({
    required this.name,
    required this.isOnline,
    required this.type,
    required this.date,
    required this.time,
  });
}
