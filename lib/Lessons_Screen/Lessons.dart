import 'package:flutter/material.dart';

class Lessons extends StatefulWidget {
  const Lessons({super.key});

  @override
  State<Lessons> createState() => _LessonsState();
}

class _LessonsState extends State<Lessons> {
  final List<ButtonInfo> buttons = [
    ButtonInfo(
      icon: Icons.star,
      text: 'Favorites',
      onPressed: () {
        // Navigate to Favorites screen
        print('Navigate to Favorites screen');
      },
    ),
    ButtonInfo(
      icon: Icons.person,
      text: 'Beginner',
      onPressed: () {
        // Navigate to Beginner screen
        print('Navigate to Beginner screen');
      },
    ),
    ButtonInfo(
      icon: Icons.directions_walk_sharp,
      text: 'Intermediate',
      onPressed: () {
        // Navigate to Intermediate screen
        print('Navigate to Intermediate screen');
      },
    ),
    ButtonInfo(
      icon: Icons.directions_run,
      text: 'Expert',
      onPressed: () {
        // Navigate to Expert screen
        print('Navigate to Expert screen');
      },
    ),
    ButtonInfo(
      icon: Icons.gesture,
      text: 'Custom Gestures',
      onPressed: () {
        // Navigate to Custom Gestures screen
        print('Navigate to Custom Gestures screen');
      },
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: buttons[index].onPressed,
            icon: Icon(buttons[index].icon),
            label: Row(
              children: [
                Text(buttons[index].text),
                Spacer(), // Spacer to push the play button to the end
                IconButton(
                  onPressed: () {
                    // You can put any action here
                  },
                  icon: Icon(Icons.play_circle_filled),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
  
class ButtonInfo {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  ButtonInfo({
    required this.icon,
    required this.text,
    required this.onPressed,
  });
}