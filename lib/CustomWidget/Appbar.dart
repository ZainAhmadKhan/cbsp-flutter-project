import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final bool showSearchIcon; // New property to control the visibility of the search icon
  final VoidCallback onSearchPressed;
  final VoidCallback onSettingsPressed;

  const CustomAppBar({
    Key? key,
    this.height = kToolbarHeight,
    required this.showSearchIcon,
    required this.onSearchPressed,
    required this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[300],
      title: Row(
        children: [
          Text(
            'Comm ',
            style: TextStyle(
              fontSize: 25,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Fusion',
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        if (showSearchIcon) // Show search icon only if showSearchIcon is true
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