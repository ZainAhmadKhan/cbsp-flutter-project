import 'package:cbsp_flutter_app/CustomWidget/RoundedTextField.dart';
import 'package:cbsp_flutter_app/SignInScreens/UploadProfileImg.dart';
import 'package:flutter/material.dart';


class SiginupScreen extends StatefulWidget {
  const SiginupScreen({super.key});

  @override
  State<SiginupScreen> createState() => _SiginupScreenState();
}

class _SiginupScreenState extends State<SiginupScreen> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        surfaceTintColor: Colors.blue[100],
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.blue,size: 40,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'SignUp',
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    'Add your Sign Up details',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
                SizedBox(height: 10),
                RoundedTextField(
                  hintText: 'Name',
                  icon: Icons.person,
                ),
                SizedBox(height: 10),
                RoundedTextField(
                  hintText: 'Email',
                  icon: Icons.email,
                ),
                SizedBox(height: 10),
                RoundedTextField(
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                 SizedBox(height: 10),
                RoundedTextField(
                  hintText: 'Confirm Password',
                  icon: Icons.lock,
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
                    labelText: 'Disabilty',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2), // Change border color when focused
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadProfileImage()),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    minimumSize: Size(250, 50),
                  ),
                  child: Text('Next'),
                ),
               ],
            ),
          ),
          ),
        ),
    );
  }
}

class RoundedTextField2 extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final VoidCallback onTap;
  final String value;

  RoundedTextField2({
    required this.hintText,
    required this.icon,
    required this.onTap,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixIcon: Icon(Icons.arrow_drop_down),
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: Colors.blue, width: 2), // Change border color when focused
        ),
        labelText: value.isNotEmpty ? hintText : null,
      ),
      controller: TextEditingController(text: value),
    );
  }
}