import 'package:cbsp_flutter_app/Contacts_Screen/AddFriend.dart';
import 'package:cbsp_flutter_app/Settings/Settings.dart';
import 'package:flutter/material.dart';

class ShowAllContacts extends StatefulWidget {
  const ShowAllContacts({Key? key}) : super(key: key);

  @override
  State<ShowAllContacts> createState() => _ShowAllContactsState();
}

class _ShowAllContactsState extends State<ShowAllContacts> {
  final List<UserHistory> userhistory = [
  UserHistory(
    name: "John Doe",
    about: "Software Engineer",
    isOnline: true,
    lastSeen: "Online",
  ),
  UserHistory(
    name: "Jane Smith",
    about: "Graphic Designer",
    isOnline: false,
    lastSeen: "7 min ago",
  ),
  UserHistory(
    name: "Alice Johnson",
    about: "Web Developer",
    isOnline: true,
    lastSeen: "4pm",
  ),
  UserHistory(
    name: "Bob Brown",
    about: "Data Scientist",
    isOnline: false,
    lastSeen: "2am",
  ),
  UserHistory(
    name: "Eve Taylor",
    about: "UI/UX Designer",
    isOnline: true,
    lastSeen: "Online",
  ),
  UserHistory(
    name: "Mike Thompson",
    about: "Product Manager",
    isOnline: false,
    lastSeen: "3 hours ago",
  ),
  UserHistory(
    name: "Sara Johnson",
    about: "Marketing Specialist",
    isOnline: false,
    lastSeen: "Yesterday",
  ),
  UserHistory(
    name: "Alex Williams",
    about: "Backend Developer",
    isOnline: true,
    lastSeen: "Online",
  ),
  UserHistory(
    name: "Emily Brown",
    about: "Frontend Developer",
    isOnline: false,
    lastSeen: "1 week ago",
  ),
  UserHistory(
    name: "Ryan Miller",
    about: "Systems Analyst",
    isOnline: false,
    lastSeen: "2 days ago",
  ),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar2(
        onAddFriendPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFriend()),
          );
        },
        onSearchPressed: () {
          // Add search functionality
        },
        onSettingsPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Settings()),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: userhistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/person.png'), // Dummy image
                    ),
                    title: Text(userhistory[index].name),
                    subtitle: Text(userhistory[index].about),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              userhistory[index].lastSeen,
                              style: TextStyle(
                                color: userhistory[index].isOnline ? Colors.green : Colors.black, fontSize: 12
                              ),
                            ),
                            SizedBox(height: 5), // Adjust spacing as needed
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
                                  backgroundColor: userhistory[index].isOnline ? Colors.green : Colors.grey,
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

class CustomAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final VoidCallback onSearchPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onAddFriendPressed;

  const CustomAppBar2({
    Key? key,
    this.height = kToolbarHeight,
    required this.onSearchPressed,
    required this.onSettingsPressed,
    required this.onAddFriendPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[300],
      title: const Row(
        children: [
          Text(
            'Select contact',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onAddFriendPressed,
          icon: Icon(
            Icons.group_add_rounded,
            color: Colors.black,
          ),
        ),
        IconButton(
          onPressed: onSearchPressed,
          icon: Icon(
            Icons.search,
            color: Colors.black,
          ),
        ),
        IconButton(
          onPressed: onSettingsPressed,
          icon: Icon(
            Icons.settings,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
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
