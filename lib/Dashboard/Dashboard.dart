import 'package:cbsp_flutter_app/CallLogs_Screen/CallLogs.dart';
import 'package:cbsp_flutter_app/Contacts_Screen/contacts.dart';
import 'package:cbsp_flutter_app/CustomWidget/Appbar.dart';
import 'package:cbsp_flutter_app/CustomWidget/TopNavigatorBar.dart'; 
import 'package:cbsp_flutter_app/Lessons_Screen/Lessons.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Contacts(),
    CallLogs(),
    Lessons(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onSearchPressed: () {
          // Add search functionality
        },
        onSettingsPressed: () {
          // Add settings functionality
        },
      ),
      body: Column(
        children: [

          TopNavigator(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
