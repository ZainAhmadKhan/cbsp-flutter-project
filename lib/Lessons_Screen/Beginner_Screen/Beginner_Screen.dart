import 'package:cbsp_flutter_app/Lessons_Screen/Beginner_Screen/Alphabets/Alphabets.dart';
import 'package:cbsp_flutter_app/Lessons_Screen/Beginner_Screen/Words/Words.dart';
import 'package:flutter/material.dart';

class Beginner extends StatefulWidget {
  const Beginner({super.key});

  @override
  State<Beginner> createState() => _BeginnerState();
}

class _BeginnerState extends State<Beginner> {
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
        image: 'assets/Images/Alphabets.png',
        text: 'Alphabets',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Alphabets()),
          );
        },
      ),
      ButtonInfo(
        image: 'assets/Images/Words.png',
        text: 'Words',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Words()),
          );          
        },
      ),
    ];
  }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.black, 
          ),
        backgroundColor: Colors.grey[300],
        title: const Row(
          children: [
            Text(
              'Beginner Level',
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
                        onPressed: button.onPressed,
                        icon: Icon(Icons.play_circle_filled,color: Colors.black,),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 50,)
      ],
    ),
    );
  }
}
    

class ButtonInfo {
  final String image;
  final String text;
  final VoidCallback onPressed;

  ButtonInfo({required this.image, required this.text, required this.onPressed});
}


