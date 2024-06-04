import 'package:cbsp_flutter_app/Lessons_Screen/PlaySign.dart';
import 'package:flutter/material.dart';

class Alphabets extends StatefulWidget {
  const Alphabets({Key? key}) : super(key: key);

  @override
  State<Alphabets> createState() => _AlphabetsState();
}

class _AlphabetsState extends State<Alphabets> {
  final List<Color> buttonColors = [
    Colors.lightBlue[100]!,
    Colors.lightGreen[100]!,
    Colors.red[100]!,
    Colors.yellow[100]!,
    Colors.purple[100]!,
  ];

  // List of alphabets
  final List<String> alphabets = List.generate(26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.grey[300],
        title: const Text(
          'A-B Alphabets',
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: alphabets.length,
        itemBuilder: (context, index) {
          final alphabet = alphabets[index];
          final colorIndex = index % buttonColors.length; // Loop through colors
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlaySign(alphabet: alphabet)),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: buttonColors[colorIndex],
                padding: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                alphabet,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
