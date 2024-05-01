import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
class ApiHandler {
  static const baseUrl = 'http://192.168.43.55:8000/user';

static Future<bool> checkConnection() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/check_connection'));
    if (response.statusCode == 200) 
    {
      return true;
    } 
    else 
    {
      return false;
    }
  } catch (e) {
      return false;
  }
}

  static Future<bool> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Successful login
        return true;
      } else {
        // Login failed
        return false;
      }
    } catch (e) {
      // Exception occurred
      return false;
    }
  }

static Future<int?> signupUser(String fname, String lname, String email, String password, DateTime dateOfBirth, String disability, String bio, String accountStatus, int onlinestatus, DateTime registrationdate) async {
  try {
    // Set the time components of dateOfBirth and registrationdate to midnight (00:00:00)
    dateOfBirth = DateTime(dateOfBirth.year, dateOfBirth.month, dateOfBirth.day);
    registrationdate = DateTime(registrationdate.year, registrationdate.month, registrationdate.day);

    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'fname': fname,
        'lname': lname,
        'DateOfBirth': dateOfBirth.toIso8601String(), // Convert DateTime to ISO 8601 string
        'password': password,
        'email': email,         
        'disability_type': disability,
        'account_status': accountStatus,
        'bio_status': bio,
        'registration_date': registrationdate.toIso8601String(), // Convert DateTime to ISO 8601 string
        'online_status': onlinestatus,
      }),
    );

    if (response.statusCode == 200) {
      // Successful signup
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['Id']; // Return the user ID
    } else {
      // Signup failed
      return null;
    }
  } catch (e) {
    // Exception occurred
    print('Exception occurred during signup: $e');
    return null;
  }
}



  static Future<bool> uploadProfilePicture(int userId, File profileImage) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/uploadprofilepicture/$userId'));

      var stream = http.ByteStream(profileImage.openRead());
      var length = await profileImage.length();

      var multipartFile = http.MultipartFile(
        'profile_picture',
        stream,
        length,
        filename: profileImage.path.split('/').last,
      );

      request.files.add(multipartFile);

      var response = await request.send();

      if (response.statusCode == 200) {
        return true; // Successful upload
      } else {
        return false; // Upload failed
      }
    } catch (e) {
      return false; // Exception occurred
    }
  }
}