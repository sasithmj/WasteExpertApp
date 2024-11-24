import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:wasteexpert/models/WasteReport/WasteReportModel.dart';
import 'package:wasteexpert/Config.url.dart' as UrlConfig;

class ImageRecognitionController {
  final String recognizeWasteUrl = UrlConfig.recognizeWasteUrl;

  Future<List<Map<String, dynamic>>> recognizeWaste(
      {required File photo}) async {
    print("Starting recognizeWaste with photo path: ${photo.path}");

    var request = http.MultipartRequest('POST', Uri.parse(recognizeWasteUrl));

    request.files.add(await http.MultipartFile.fromPath(
      'Photo',
      photo.path,
      filename: basename(photo.path),
    ));

    print("Sending request to $recognizeWasteUrl");

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      print("Response status code: ${response.statusCode}");
      print("Response body: $responseBody");
      print("Decoded JSON response: $jsonResponse");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Report successfully created with data: ${jsonResponse['data']}');
        // Expecting 'data' to be a list of maps
        return List<Map<String, dynamic>>.from(
            jsonResponse['data']); // Return the response data as a list of maps
      } else {
        print('Failed to create report: ${response.reasonPhrase}');
        throw Exception('Failed to recognize waste');
      }
    } catch (e) {
      print("Exception during HTTP request: $e");
      throw Exception('Failed to recognize waste due to an error: $e');
    }
  }
}
