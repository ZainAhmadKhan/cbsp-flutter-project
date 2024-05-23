import 'dart:convert';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:http/http.dart' as http;


class ContactApiHandler {
  static const baseUrl = '$Url/contacts';

  static Future<List<UserContact>> getUserContacts(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId/contacts'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((contactJson) => UserContact.fromJson(contactJson)).toList();
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  static Future<void> addNewContact(int userId, int contactId, int isBlocked) async {
  final Map<String, dynamic> requestData = {
    'user_id': userId,
    'contact_id': contactId,
    'is_blocked': isBlocked,
  };

  try {
    final http.Response response = await http.post(
      Uri.parse('$baseUrl/add'),
      body: jsonEncode(requestData),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('User added as a contact successfully');
    } else {
      print('Failed to add user as a contact: ${response.statusCode}');
    }
  } catch (e) {
    print('Error adding user as a contact: $e');
  }
}
}
class UserContact {
  final String fname;
  final String lname;
  final String profilePicture;
  final String accountStatus;
  final String bioStatus;
  final int onlineStatus;

  UserContact({
    required this.fname,
    required this.lname,
    required this.profilePicture,
    required this.accountStatus,
    required this.bioStatus,
    required this.onlineStatus,
  });

  factory UserContact.fromJson(Map<String, dynamic> json) {
    return UserContact(
      fname: json['fname'],
      lname: json['lname'],
      profilePicture: json['profile_picture'],
      accountStatus: json['account_status'],
      bioStatus: json['bio_status'],
      onlineStatus: json['online_status'], 
    );
  }
}
