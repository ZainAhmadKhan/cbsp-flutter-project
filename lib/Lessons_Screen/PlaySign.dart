import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:flutter/material.dart';

class PlaySign extends StatefulWidget {
  final String alphabet;

  const PlaySign({Key? key, required this.alphabet}) : super(key: key);

  @override
  State<PlaySign> createState() => _PlaySignState();
}

class _PlaySignState extends State<PlaySign> {
  int currentIndex = 0; // Index of the current alphabet
  List<String> alphabets = List.generate(26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));

  @override
  void initState() {
    super.initState();
    // Set currentIndex to the index of the passed alphabet
    currentIndex = alphabets.indexOf(widget.alphabet.toUpperCase());
  }

  String get currentAlphabet => alphabets[currentIndex];

  String get alphabetImage => '$Url/profile_pictures/gif/asl/alphabets/${currentAlphabet.toLowerCase()}.gif';

  void goToNextAlphabet() {
    setState(() {
      currentIndex = (currentIndex + 1) % alphabets.length;
    });
  }

  void goToPreviousAlphabet() {
    setState(() {
      currentIndex = (currentIndex - 1 + alphabets.length) % alphabets.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, 
        ),
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Play Signs',
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Center(
            child: Text(
              currentAlphabet, // Displaying the current alphabet
              style: TextStyle(
                fontSize: 80, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20), // Adding some space between the alphabet and the image
          Center(
            child: Image.network(
              alphabetImage,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) => Text('Error loading image'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                goToPreviousAlphabet();
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                goToNextAlphabet();
              },
            ),
          ],
        ),
      ),
    );
  }
}
