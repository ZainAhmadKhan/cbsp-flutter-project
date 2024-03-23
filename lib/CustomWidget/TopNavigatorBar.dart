import 'package:flutter/material.dart';

class TopNavigator extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  const TopNavigator({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300], // Customize the background color as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.people, 'Contacts', 0),
          _buildNavItem(Icons.call, 'Call Logs', 1),
          _buildNavItem(Icons.book, 'Lessons', 2),
        ],
      ),
    );
  }

 Widget _buildNavItem(IconData icon, String label, int index) {
  final isSelected = selectedIndex == index;
  final color = isSelected ? Colors.blue : Colors.grey;

  return GestureDetector(
    onTap: () => onItemTapped(index),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color,size: 25,),
            Text(
              label,
              style: TextStyle(color: color,fontSize: 15),
            ),
          ],
        ),
        if (isSelected)
          Positioned(
            bottom: 0,
            child: Container(
              width: 100, // Adjust the width of the line as needed
              height: 2,
              color: Colors.blue,
            ),
          ),
      ],
    ),
  );
}
}



