import 'package:cbsp_flutter_app/CustomWidget/RoundedTextField.dart';
import 'package:cbsp_flutter_app/Dashboard/Dashboard.dart';
import 'package:cbsp_flutter_app/SignInScreens/Signup.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body:SingleChildScrollView(
          child: Center(
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 150),
                Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Center(
                  child: Text(
                    'Add your login details',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
                SizedBox(height: 20),
                RoundedTextField(
                  hintText: 'Email',
                  icon: Icons.email,
                ),
                SizedBox(height: 10.0),
                RoundedTextField(
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dashboard()),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    minimumSize: Size(250, 50),
                  ),
                  child: Text('Login'),
                ),
                SizedBox(height: 30),
                Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an Account?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SiginupScreen()),
                          );
                        }, 
                        child: Text(
                          "Signup",
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                    
                      )
                    ],
                  ),
                )

              ],
            ),
                ),
          ),
        ),
    );
  }
}
