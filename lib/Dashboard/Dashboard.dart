import 'package:cbsp_flutter_app/Dashboard/Search.dart';
import 'package:cbsp_flutter_app/GroupChat/GroupChat.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart';
import 'package:flutter/material.dart';
import 'package:cbsp_flutter_app/CallLogs_Screen/CallLogs.dart';
import 'package:cbsp_flutter_app/Contacts_Screen/contacts.dart';
import 'package:cbsp_flutter_app/Lessons_Screen/Lessons.dart';
import 'package:cbsp_flutter_app/Settings/Settings.dart';
import 'package:cbsp_flutter_app/CustomWidget/Appbar.dart';
import 'package:cbsp_flutter_app/CustomWidget/TopNavigatorBar.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late PageController _pageController;
  int _selectedIndex = 0;
   
 @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        _selectedIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showSearchIcon: _selectedIndex != 2,
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
      body: Column(
            children: [
              TopNavigator(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                 children: [
                  Contacts(),
                  CallLogs(),
                  GroupChat(),
                  Lessons(),
                ],
                ),
              ),
            ],
          ),
    );
  }
}
