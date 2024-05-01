import 'package:cbsp_flutter_app/ButtonsAndVariables/Buttons.dart';
import 'package:flutter/material.dart';
import 'package:cbsp_flutter_app/CustomWidget/RoundedTextField.dart';
import 'package:cbsp_flutter_app/SignInScreens/UploadProfileImg.dart';

class SiginupScreen extends StatefulWidget {
  const SiginupScreen({Key? key}) : super(key: key);

  @override
  State<SiginupScreen> createState() => _SiginupScreenState();
}

class _SiginupScreenState extends State<SiginupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  DateTime? selectedDate;
  String disabilityValue = 'Normal Person';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your name');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your email');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      _showErrorMessage('Please enter a valid email');
      return false;
    }

    if (passwordController.text.isEmpty) {
      _showErrorMessage('Please enter a password');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showErrorMessage('Passwords do not match');
      return false;
    }

    if (selectedDate == null) {
      _showErrorMessage('Please select your date of birth');
      return false;
    }

    if (nameController.text.trim().split(' ').length < 2) {
      _showErrorMessage('Please enter your full name');
      return false;
    }

    return true;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return email.endsWith('@gmail.com') || email.endsWith('@yahoo.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'SignUp',
              style: TextStyle(
                fontSize: 50,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            RoundedTextField(
              hintText: 'Name',
              icon: Icons.person,
              controller: nameController,
            ),
            SizedBox(height: 10),
            RoundedTextField(
              hintText: 'Email',
              icon: Icons.email,
              controller: emailController,
            ),
            SizedBox(height: 10),
            RoundedTextField(
              hintText: 'Password',
              icon: Icons.lock,
              obscureText: true,
              controller: passwordController,
            ),
            SizedBox(height: 10),
            RoundedTextField(
              hintText: 'Confirm Password',
              icon: Icons.lock,
              controller: confirmPasswordController,
            ),
            SizedBox(height: 10),
            RoundedTextField2(
              hintText: 'Date of Birth',
              icon: Icons.calendar_today,
              onTap: () => _selectDate(context),
              value: selectedDate != null
                  ? "${selectedDate!.toLocal()}".split(' ')[0]
                  : '',
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: disabilityValue,
              onChanged: (String? value) {
                setState(() {
                  disabilityValue = value!;
                });
              },
              items: ['Normal Person', 'Blind', 'Deaf mute']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Disability',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                focusColor: Colors.blue,
              ),
            ),
            SizedBox(height: 30),
            CustomButton(
              onPressed: () {
                if (_validateForm()) {
                  String Fname = nameController.text.split(' ')[0];
                  String Lname = nameController.text.split(' ')[1];
                  DateTime Registration_date=DateTime.now();
                  String account_status="Active";
                  int online_status=1;
                  // Navigate to UploadProfileImage screen with signup data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadProfileImage(
                        fname: Fname,
                        lname: Lname,
                        email: emailController.text.trim(),
                        password: passwordController.text,
                        dateOfBirth: selectedDate!,
                        disability: disabilityValue,
                        registration_date: Registration_date,
                        account_status:account_status,
                        online_status:online_status,
                      ),
                    ),
                  );
                }
              },
              text: 'Next',
            ),
          ],
        ),
      ),
    );
  }
}
