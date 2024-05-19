import 'dart:convert';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:http/http.dart' as http;

class ParticipantsApiHandler {
static const baseUrl = '$Url/videocallparticipants';

  static Future<List<CallDetails>> fetchUserCalls(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId/calls'),
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((contactJson) => CallDetails.fromJson(contactJson)).toList();
      } catch (e) {
        print('Error parsing user calls: $e'); // Log parsing error
        throw Exception('Error parsing user calls');
      }
    } else {
      print('Failed to load user calls: ${response.statusCode}'); // Log status code
      throw Exception('Failed to load user calls');
    }
  }
}

class CallDetails {
  final int videoCallId;
  final String otherParticipantFname;
  final String otherParticipantLname;
  final String profilePicture;
  final int onlineStatus;
  final int accountStatus;
  final int isCaller;
  final DateTime endTime;
  final DateTime startTime;

  CallDetails({
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

  factory CallDetails.fromJson(Map<String, dynamic> json) {
    return CallDetails(
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