import 'package:cbsp_flutter_app/CustomSigns/CustomSigns.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Lessons extends StatefulWidget {
  const Lessons({Key? key}) : super(key: key);

  @override
  State<Lessons> createState() => _LessonsState();
}

class _LessonsState extends State<Lessons> {
  final List<Color> buttonColors = [
    Colors.lightBlue[100]!,
    Colors.lightGreen[100]!,
    Colors.red[100]!,
    Colors.yellow[100]!,
    Colors.purple[100]!,
  ];

  final List<ButtonInfo> buttons = [
    ButtonInfo(
      image: 'assets/Images/Favourite.png',
      text: 'Favorites',
      onPressed: () {
        // Navigate to Favorites screen
        print('Navigate to Favorites screen');
      },
    ),
    ButtonInfo(
      image: 'assets/Images/Beginner.png',
      text: 'Beginner',
      onPressed: () {
        // Navigate to Beginner screen
        print('Navigate to Beginner screen');
      },
    ),
    ButtonInfo(
      image: 'assets/Images/Intermediate.png',
      text: 'Intermediate',
      onPressed: () {
        // Navigate to Intermediate screen
        print('Navigate to Intermediate screen');
      },
    ),
    ButtonInfo(
      image: 'assets/Images/Expert.png',
      text: 'Expert',
      onPressed: () {
        // Navigate to Expert screen
        print('Navigate to Expert screen');
      },
    ),
    ButtonInfo(
      image: 'assets/Images/Custom1.png',
      text: 'Custom Gestures',
      onPressed: () {
        // Navigate to Custom Gestures screen
        print('Navigate to Custom Gestures screen');
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20,),
        Expanded(
          child: ListView.builder(
            itemCount: buttons.length,
            itemBuilder: (context, index) {
              final button = buttons[index];
              final color = buttonColors[index % buttonColors.length];
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: button.onPressed,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(color),
                    minimumSize: MaterialStateProperty.all(Size(double.infinity, 80)), // Height of the buttons
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          button.image,
                          width: 40, // Adjust the width of the image
                          height: 40, // Adjust the height of the image
                        ),
                      ),
                      Text(
                        button.text,
                        style: TextStyle(fontSize: 18),
                      ),
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
            },
          ),
        ),
        
        
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomSigns()),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            maximumSize: Size(300, 50),
            minimumSize: Size(300, 50)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add), // Plus icon
              SizedBox(width: 8), // Some space between the icon and the text
              Text('Add Custom Signs', style: TextStyle(fontSize: 18),),
            ],
          ),
        ),

        SizedBox(height: 50,)
      ],
    );
  }
}

class ButtonInfo {
  final String image;
  final String text;
  final VoidCallback onPressed;

  ButtonInfo({
    required this.image,
    required this.text,
    required this.onPressed,
  });
}
