import 'package:flutter/material.dart';

class CallLogs extends StatefulWidget {
  const CallLogs({super.key});

  @override
  State<CallLogs> createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
  final List<CallHistory> callHistory = [
  CallHistory(
    name: "John Doe",
    isOnline: true,
    type: "Incoming",
    date: "March 14,",
    time: "10:10 AM",
  ),
  CallHistory(
    name: "Jane Smith",
    isOnline: false,
    type: "Outgoing",
    date: "April 5,",
    time: "11:30 AM",
  ),
  CallHistory(
    name: "Alice Johnson",
    isOnline: true,
    type: "Missed",
    date: "May 21,",
    time: "1:45 PM",
  ),
  CallHistory(
    name: "Bob Brown",
    isOnline: false,
    type: "Incoming",
    date: "June 9,",
    time: "3:20 PM",
  ),
  CallHistory(
    name: "Eve Taylor",
    isOnline: true,
    type: "Outgoing",
    date: "July 17,",
    time: "5:00 PM",
  ),
  CallHistory(
    name: "Mike Thompson",
    isOnline: false,
    type: "Missed",
    date: "August 3,",
    time: "6:25 PM",
  ),
  CallHistory(
    name: "Sara Johnson",
    isOnline: false,
    type: "Incoming",
    date: "September 12,",
    time: "7:40 PM",
  ),
  CallHistory(
    name: "Alex Williams",
    isOnline: true,
    type: "Outgoing",
    date: "October 28,",
    time: "9:15 PM",
  ),
  CallHistory(
    name: "Emily Brown",
    isOnline: false,
    type: "Missed",
    date: "November 9,",
    time: "11:05 PM",
  ),
  CallHistory(
    name: "Ryan Miller",
    isOnline: false,
    type: "Incoming",
    date: "December 20,",
    time: "12:30 AM",
  ),
];

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
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
                              Icon(
                                Icons.videocam,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 5),
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
        ),
      ),

    );
  }
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
