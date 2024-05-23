import 'package:cbsp_flutter_app/APIsHandler/ContactsAPI.dart';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/Dashboard/Search.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart';
import 'package:flutter/material.dart';
import 'package:cbsp_flutter_app/Settings/Settings.dart';
import 'package:provider/provider.dart';

class ShowAllContacts extends StatefulWidget {
  final int userId;

  const ShowAllContacts({Key? key, required this.userId}) : super(key: key);

  @override
  State<ShowAllContacts> createState() => _ShowAllContactsState();
}

class _ShowAllContactsState extends State<ShowAllContacts> {
  List<User> users = [];
  List<UserContact> contacts = []; 
  List<User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final fetchedUsers = await UserApiHandler.fetchAllUsers();
      setState(() {
        users = fetchedUsers;
      });
      await _fetchContacts(widget.userId);
      _filterUsers();
    } catch (e) {
      _showErrorMessage("Failed to load users");
    }
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
  
  void _filterUsers() {
    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
    int uid = userIdProvider.userId;
    // int uid=3;
  setState(() {
    filteredUsers = users.where((user) {
      return !contacts.any((contact) => contact.profilePicture == user.profilePicture) &&
          user.id != uid;
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar2(
        onSearchPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchScreen()),
          );
        },
        onSettingsPressed: () {
          final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
          int uid = userIdProvider.userId;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Settings(userId: uid)),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  String imageUrl = '$Url/profile_pictures/';
                  String imageName = user.profilePicture;
                  String profileImage = imageUrl + imageName;
                  return ListTile(
                    leading: CircleAvatar(
                          backgroundImage: NetworkImage(profileImage), 
                        ),
                    title: Text('${user.fname} ${user.lname}'),
                    subtitle: Text(user.bioStatus!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(height: 20),
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: user.onlineStatus == 1 ? Colors.green : Colors.grey,
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                        SizedBox(width: 10),
                       IconButton(
                          icon: Icon(Icons.person_add),
                          onPressed: () {
                            ContactApiHandler.addNewContact(3, user.id, 0);
                            initState(); 
                          },
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
    );
  }
}

class CustomAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final VoidCallback onSearchPressed;
  final VoidCallback onSettingsPressed;

  const CustomAppBar2({
    Key? key,
    this.height = kToolbarHeight,
    required this.onSearchPressed,
    required this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[300],
      title: const Row(
        children: [
          Text(
            'Add Contacts',
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
