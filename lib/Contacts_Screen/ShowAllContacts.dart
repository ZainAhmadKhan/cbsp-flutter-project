import 'package:cbsp_flutter_app/APIsHandler/ContactsAPI.dart';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:cbsp_flutter_app/Dashboard/Search.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart';
import 'package:flutter/material.dart';
import 'package:cbsp_flutter_app/Settings/Settings.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShowAllContacts extends StatefulWidget {
  final int userId;

  const ShowAllContacts({Key? key, required this.userId}) : super(key: key);

  @override
  State<ShowAllContacts> createState() => _ShowAllContactsState();
}

class _ShowAllContactsState extends State<ShowAllContacts> {
  String selectedFilter = 'Username';
  List<SearchResult> searchData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _searchByUsername(int id, String username) async {
    try {
      final fetchedUser = await UserApiHandler.searchByUsername(id, username);
      setState(() {
        searchData = fetchedUser;
      });
    } catch (e) {
      _showErrorMessage("Failed to load search data");
    }
  }

  Future<void> _searchByEmail(int id, String email) async {
    try {
      final fetchedUser = await UserApiHandler.searchByEmail(id, email);
      setState(() {
        searchData = fetchedUser;
      });
    } catch (e) {
      _showErrorMessage("Failed to load search data");
    }
  }

  void _performSearch() {
    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
    int uid = userIdProvider.userId;
    String query = searchController.text;

    if (selectedFilter == 'Username') {
      _searchByUsername(uid, query);
    } else if (selectedFilter == 'Email') {
      _searchByEmail(uid, query);
    }
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
            SizedBox(height: 10),
            Text("Search Users by Username or Email"),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: 'Username',
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                ),
                Text('Username'),
                SizedBox(width: 20),
                Radio<String>(
                  value: 'Email',
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                ),
                Text('Email'),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  filled: true,
                  fillColor: Colors.grey[200], // Background color
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.grey, size: 30), // Search icon color
                    onPressed: _performSearch,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40), // Border radius
                    borderSide: BorderSide.none, // Remove border side
                  ),
                ),
                onChanged: (value) {
                  // Optionally trigger search on change if desired
                },
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchData.length,
                itemBuilder: (context, index) {
                  final user = searchData[index];
                  String imageUrl = '$Url/profile_pictures/';
                  String imageName = user.profilePicture;
                  String profileImage = imageUrl + imageName;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    title: Text('${user.fname} ${user.lname}'),
                    subtitle: Text("@${user.username}", selectionColor: Colors.blue),
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
                          icon: Icon(
                            user.isFriend ? Icons.done_all : Icons.person_add,
                            color: user.isFriend ? Colors.green : Colors.blue,
                          ),
                          onPressed: user.isFriend
                              ? null
                              : () {
                                  final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
                                  int uid = userIdProvider.userId;
                                  ContactApiHandler.addNewContact(uid, user.userId, 0);
                                  setState(() {
                                    user.isFriend = true; // Update the local state
                                  });
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
            'Add Contact',
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

