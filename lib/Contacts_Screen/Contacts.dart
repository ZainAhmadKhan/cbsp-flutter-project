import 'dart:convert';
import 'package:cbsp_flutter_app/APIsHandler/ContactsAPI.dart';
import 'package:cbsp_flutter_app/Contacts_Screen/ShowAllContacts.dart';
import 'package:flutter/material.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart'; 
import 'package:provider/provider.dart';

import '../CustomWidget/GlobalVariables.dart';

class Contacts extends StatefulWidget {
  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<UserContact> contacts = []; 
  int uid=0;
 
  @override
  void initState() {
    super.initState();
    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
    int uid=userIdProvider.userId;
    print("InitState $uid");
    _fetchContacts(uid); 
  }

  Future<void> _fetchContacts(int userid) async {
    try {
      final fetchedContacts = await ContactApiHandler.getUserContacts(userid);
      print("In function $userid");
      setState(() {
      contacts = fetchedContacts;
    });
    // for(int i=0;i<=contacts.length;i++)
    // {
    //   print(contacts[i].profilePicture);

    // }
    } catch (e) {
      _showErrorMessage("No Contacts Load Error!");
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // Consumer<UserIdProvider>(
              //   builder: (context, userIdProvider, _) {
              //     return Text('User ID: ${userIdProvider.userId}');
              //   },
              // ),
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    String image=contact.profilePicture;
                    String ImageUrl = '$Url/images/profile/$image';
                    return ListTile(                   
                      leading: CircleAvatar(                     
                        backgroundImage: NetworkImage(ImageUrl), 
                      ),
                      title: Text('${contact.fname} ${contact.lname}'),
                      subtitle: Text(contact.bioStatus),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: contact.onlineStatus==1 ? Colors.green : Colors.grey,
                          ),
                          SizedBox(width: 20),
                          Icon(
                            Icons.videocam,
                            color: Colors.grey,
                            size: 32,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a screen to show all contacts
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
