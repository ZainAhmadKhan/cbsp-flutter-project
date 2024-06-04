import 'package:cbsp_flutter_app/APIsHandler/ContactsAPI.dart';
import 'package:cbsp_flutter_app/Contacts_Screen/UserProfile.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<UserContact> contacts = [];
  List<UserContact> filteredContacts = [];

  @override
  void initState() {
    super.initState();
    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
    int uid = userIdProvider.userId;
    _fetchContacts(uid);
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _fetchContacts(int userid) async {
    try {
      final fetchedContacts = await ContactApiHandler.getUserContacts(userid);
      setState(() {
        contacts = fetchedContacts;
      });
    } catch (e) {
      _showErrorMessage("No Contacts Load Error!");
    }
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredContacts = [];
      });
      return;
    }

    final results = contacts.where((contact) {
      final fullName = '${contact.fname} ${contact.lname}'.toLowerCase();
      final searchQuery = query.toLowerCase();

      return fullName.contains(searchQuery);
    }).toList();

    setState(() {
      filteredContacts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, 
        ),
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Search Contacts',
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: Icon(Icons.search, color: Colors.grey, size: 30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _filterContacts(value);
              },
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: filteredContacts.isEmpty
          ? Center(
              child: Text(
                'No contacts found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                String imageUrl = '$Url/profile_pictures/';
                String imageName = contact.profilePicture;
                String profileImage = imageUrl + imageName;
                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserProfile(userId: contact.id)), 
                      );
                    },
                    
                    child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    title: Text('${contact.fname} ${contact.lname}'),
                    subtitle: Text(contact.bioStatus!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 10),
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: contact.onlineStatus == 1
                              ? Colors.green
                              : Colors.grey,
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
                            int uid = userIdProvider.userId;
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => VideoCallScreen(userId: uid)),
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
                  )
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
