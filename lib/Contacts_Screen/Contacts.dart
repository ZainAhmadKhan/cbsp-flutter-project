import 'package:cbsp_flutter_app/Contacts_Screen/ShowAllContacts.dart';
import 'package:flutter/material.dart';

class Contacts extends StatefulWidget {
  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final List<User> users = [
    User(name: "John Doe", about: "Software Engineer", isOnline: true),
    User(name: "Jane Smith", about: "Graphic Designer", isOnline: false),
    User(name: "Alice Johnson", about: "Web Developer", isOnline: true),
    User(name: "Bob Brown", about: "Data Scientist", isOnline: false),
    User(name: "Eve Taylor", about: "UI/UX Designer", isOnline: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(          
                      backgroundImage: AssetImage('assets/person.png'), // Dummy image
                    ),
                    title: Text(users[index].name),
                    subtitle: Text(users[index].about),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 5),
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: users[index].isOnline
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShowAllContacts()),
          );
        },
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(Icons.videocam),
      ),
    );
  }
}
   

class User {
  final String name;
  final String about;
  final bool isOnline;


  User({required this.name, required this.about, required this.isOnline});
}
