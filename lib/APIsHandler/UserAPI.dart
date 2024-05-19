import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
class UserApiHandler {
  static const baseUrl = '$Url/user';

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

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
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
        Map<String, dynamic> data = jsonDecode(response.body);
        return {"success": true, "user_id": data["user_id"]};
      } else {
        // Login failed
        return {"success": false};
      }
    } catch (e) {
      // Exception occurred
      return {"success": false};
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

  static Future<UserDetails> fetchUserDetails(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userdetails/$userId'), 
    );

    if (response.statusCode == 200) {
      return UserDetails.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user details');
    }
  }
}

class UserDetails {
  final String fname;
  final String lname;
  final DateTime dateOfBirth;
  final String password;
  final String profilePicture;
  final String email;
  final String disabilityType;
  final String accountStatus;
  final String bioStatus;
  final DateTime registrationDate;
  final int onlineStatus;

  UserDetails({
    required this.fname,
    required this.lname,
    required this.dateOfBirth,
    required this.password,
    required this.profilePicture,
    required this.email,
    required this.disabilityType,
    required this.accountStatus,
    required this.bioStatus,
    required this.registrationDate,
    required this.onlineStatus,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      fname: json['fname'],
      lname: json['lname'],
      dateOfBirth: DateTime.parse(json['DateOfBirth']),
      password: json['password'],
      profilePicture: json['profile_picture'],
      email: json['email'],
      disabilityType: json['disability_type'],
      accountStatus: json['account_status'],
      bioStatus: json['bio_status'],
      registrationDate: DateTime.parse(json['registration_date']),
      onlineStatus: json['online_status'],
    );
  }
}