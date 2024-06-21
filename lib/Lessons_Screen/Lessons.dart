import 'package:cbsp_flutter_app/ButtonsAndVariables/Buttons.dart';
import 'package:cbsp_flutter_app/CustomSigns/CustomSigns.dart';
import 'package:cbsp_flutter_app/Lessons_Screen/Beginner_Screen/Beginner_Screen.dart';
import 'package:cbsp_flutter_app/Lessons_Screen/CustomSign/CustomSign.dart';
import 'package:cbsp_flutter_app/Lessons_Screen/Expert_Screen/Expert_Screen.dart';
import 'package:cbsp_flutter_app/Lessons_Screen/Favourites_Screen/Favouites_Screen.dart';
import 'package:cbsp_flutter_app/Lessons_Screen/Intermediate_Screen/Intermediate_Screen.dart';
import 'package:flutter/material.dart';

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

  late List<ButtonInfo> buttons;

  @override
  void initState() {
    super.initState();
    buttons = initializeButtons();
  }

  List<ButtonInfo> initializeButtons() {
    return [
      ButtonInfo(
        image: 'assets/Images/Favourite.png',
        text: 'Favorites',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Favorites()),
          );
        },
      ),
      ButtonInfo(
        image: 'assets/Images/Beginner.png',
        text: 'Beginner',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Beginner()),
          );
        },
      ),
      ButtonInfo(
        image: 'assets/Images/Intermediate.png',
        text: 'Intermediate',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Intermediate()),
          );
        },
      ),
      ButtonInfo(
        image: 'assets/Images/Expert.png',
        text: 'Expert',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Expert()),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40,),
        Expanded(
          child: ListView.builder(
            itemCount: buttons.length,
            itemBuilder: (context, index) {
              final button = buttons[index];
              final color = buttonColors[index % buttonColors.length];
              return Padding(
                padding: const EdgeInsets.all(20.0),
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
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      Spacer(), // Spacer to push the play button to the end
                      IconButton(
                        icon: Icon(Icons.play_circle_filled, color: Colors.black),
                        onPressed: button.onPressed
                       
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
        onPressed: ()
        {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomSign()),
          );    
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Fixed background color
          minimumSize: Size(300, 50),
        ),
        child: Text(
          "+ Add Custom Sign",
          style: TextStyle(color: Colors.white, fontSize: 18), // Fixed text color
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

  ButtonInfo({required this.image, required this.text, required this.onPressed});
}
