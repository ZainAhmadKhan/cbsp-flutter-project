import 'package:flutter/material.dart';

class CallLogs extends StatefulWidget {
  const CallLogs({super.key});

  @override
  State<CallLogs> createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Logs'),
      ),
      backgroundColor: Colors.white,
        body:const SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                
                ],
              ),
            ),
          ),
        ),    
    );
  }
}

 