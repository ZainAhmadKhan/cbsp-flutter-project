import 'dart:convert';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:http/http.dart' as http;

import '../Contacts_Screen/UserProfile.dart';

class ParticipantsApiHandler {
static const baseUrl = '$Url/videocallparticipants';


  static Future<List<ContactCallLog>> fetchCallLogs(int userId, int contactId) async {
    List<UserCallDetails> allCallLogs = [];

     final response = await http.get(
      Uri.parse('$baseUrl/$userId/calls/$contactId'));

     if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((contactJson) => ContactCallLog.fromJson(contactJson)).toList();
      } catch (e) {
        print('Error parsing user call logs: $e'); // Log parsing error
        throw Exception('Error parsing user call logs');
      }
    } else {
      print('Failed to load user call logs: ${response.statusCode}'); // Log status code
      throw Exception('Failed to load user call logs');
    }
  }

  static Future<List<UserCallDetails>> fetchAllUserCalls(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId/calls'),
    );

    if (response.statusCode == 200) {
      try {
        return (json.decode(response.body) as List<dynamic>)
        .map((contactJson) => UserCallDetails.fromJson(contactJson))
        .toList();
      } catch (e) {
        print('\n'+response.body);
        print('URL is : $baseUrl/$userId/calls');
        print('Error parsing user calls: $e'); // Log parsing error
        throw Exception('Error parsing user calls');
      }
    } else {
      print('Failed to load user calls: ${response.statusCode}'); // Log status code
      throw Exception('Failed to load user calls');
    }
  }
}
class UserCallDetails {
  final int id;
  final String username;
  final String profilePicture;
  final String disabilityType;
  final String fname;
  final String lname;
  final String accountStatus;
  final String bioStatus;
  final int onlineStatus;
  final int videoCallId;
  final String? acceptTime;
  final String? endTime;
  final int isCaller;

  UserCallDetails({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.disabilityType,
    required this.fname,
    required this.lname,
    required this.accountStatus,
    required this.bioStatus,
    required this.onlineStatus,
    required this.videoCallId,
     this.acceptTime,
     this.endTime,
    required this.isCaller,
  });

  factory UserCallDetails.fromJson(Map<String, dynamic> json) {
    return UserCallDetails(
      id: json['Id'],
      username: json['Username'],
      profilePicture: json['ProfilePicture'],
      disabilityType: json['DisabilityType'],
      fname: json['Fname'],
      lname: json['Lname'],
      accountStatus: json['AccountStatus'],
      bioStatus: json['BioStatus'],
      onlineStatus: json['OnlineStatus'],
      videoCallId: json['VideoCallId'],
      acceptTime: json['AcceptTime'],
      endTime: json['EndTime'],
      isCaller: json['isCaller'],
    );
  }
}
class ContactCallLog {
  final int videoCallId;
  final String otherParticipantFname;
  final String otherParticipantLname;
  final String profilePicture;
  final int onlineStatus;
  final String accountStatus;
  final int isCaller;
  final DateTime endTime;
  final DateTime startTime;

  ContactCallLog({
    required this.videoCallId,
    required this.otherParticipantFname,
    required this.otherParticipantLname,
    required this.profilePicture,
    required this.onlineStatus,
    required this.accountStatus,
    required this.isCaller,
    required this.endTime,
    required this.startTime,
  });

  factory ContactCallLog.fromJson(Map<String, dynamic> json) {
    return ContactCallLog(
      videoCallId: json['VideoCallId'],
      otherParticipantFname: json['OtherParticipantFname'],
      otherParticipantLname: json['OtherParticipantLname'],
      profilePicture: json['ProfilePicture'],
      onlineStatus: json['OnlineStatus'],
      accountStatus: json['AccountStatus'],
      isCaller: json['isCaller'],
      endTime: DateTime.parse(json['EndTime']),
      startTime: DateTime.parse(json['StartTime']),
    );
  }
}


