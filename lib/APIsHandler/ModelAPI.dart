import 'dart:convert';
import 'dart:io';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ModelAPI {
  static const baseUrl = '$Url/asl-Updatedsigns';

  static Future<Map<String, dynamic>> detectAlphabets(File imageFile) async {
    final url = Uri.parse('$baseUrl/detect_hand');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to detect hand: ${response.reasonPhrase}');
    }
  }
}
