import 'package:cbsp_flutter_app/ButtonsAndVariables/Buttons.dart';
import 'package:cbsp_flutter_app/APIsHandler/UserAPI.dart';
import 'package:cbsp_flutter_app/Provider/UserIdProvider.dart';
import 'package:flutter/material.dart';
import 'package:cbsp_flutter_app/CustomWidget/RoundedTextField.dart';
import 'package:cbsp_flutter_app/Dashboard/Dashboard.dart';
import 'package:cbsp_flutter_app/SignInScreens/Signup.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 150),
                Column(
                  children: [
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
                      controller: emailController,
                    ),
                    SizedBox(height: 10.0),
                    RoundedTextField(
                      hintText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                      controller: passwordController,
                    ),
                    SizedBox(height: 40),
                    CustomButton(
                      onPressed: () async {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();
                        
                        if (email.isEmpty || password.isEmpty) {
                          // Display error message if email or password is empty
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please enter email and password'),
                            duration: Duration(seconds: 2),
                          ));
                          return;
                        }
                        // Perform login request
                        Map<String, dynamic> loginResult = await UserApiHandler.loginUser(email, password);
                        bool isLoggedIn = loginResult["success"];

                       if (isLoggedIn) {
                        int userId = loginResult["user_id"];

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Provider.of<UserIdProvider>(context, listen: false).setUserId(userId);
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Dashboard()),
                        );
                      } else {
                          // Display login failed message
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Login failed. Please try again.'),
                            duration: Duration(seconds: 2),
                          ));
                        }
                      },
                      text: 'Login',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
                    