import 'package:flutter/material.dart';

class Expert extends StatefulWidget {
  const Expert({super.key});

  @override
  State<Expert> createState() => _ExpertState();
}

class _ExpertState extends State<Expert> {
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
              'Expert Level',
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}