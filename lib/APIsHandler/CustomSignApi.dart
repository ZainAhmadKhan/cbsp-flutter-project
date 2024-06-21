import 'dart:convert';
import 'dart:io';
import 'package:cbsp_flutter_app/CustomWidget/GlobalVariables.dart';
import 'package:http/http.dart' as http;


class ModelAPI {
  static const baseUrl = '$Url/testing-CustomSigns';

  static Future<void> trainCustomSign(String user, String label, List<File> images) async {
    var uri = Uri.parse('$baseUrl/train/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['user'] = user;
    request.fields['label'] = label;
    
    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Training successful');
    } else {
      print('Training failed');
    }
  }

  static Future<String?> predictCustomSign(String user, File image) async {
    var uri = Uri.parse('$baseUrl/predict');
    var request = http.MultipartRequest('POST', uri);
    request.fields['user'] = user;
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var prediction = jsonDecode(responseData)['prediction'];
      return prediction;
    } else {
      print('Prediction failed');
      return null;
    }
  }

}
