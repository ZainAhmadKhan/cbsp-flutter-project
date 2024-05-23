import 'package:cbsp_flutter_app/Contacts_Screen/UserProfile.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  String selectedFilter = 'Username';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.grey[300],
      title: const Row(
        children: [
          Text(
            'Search Friends',
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ), 
      ),
      body: Column(
        children: [
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
              decoration: InputDecoration(
                hintText: 'Search...',
                filled: true,
                fillColor: Colors.grey[200], // Background color
                suffixIcon: Icon(Icons.search, color: Colors.grey,size: 30,), // Search icon color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40), // Border radius
                  borderSide: BorderSide.none, // Remove border side
                ),
              ),
              onChanged: (value) {
                // Perform search action
              },
            ),
          ),
          SizedBox(height: 10),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: userhistory.length,
          //     itemBuilder: (context, index) {
          //       return ListTile(
          //         leading: CircleAvatar(
          //             backgroundImage: AssetImage('assets/person.png'), // Dummy image
          //           ),
          //         title: Text(userhistory[index].name),
          //         subtitle: Text(userhistory[index].about),
          //         trailing: IconButton(
          //           icon: Icon(Icons.group_add),
          //           onPressed: () {
          //             // Navigator.push(
          //             //   context,
          //             //   MaterialPageRoute(builder: (context) => UserProfile()),
          //             // );
          //           },
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}