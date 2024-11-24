import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:wasteexpert/models/WasteReport/WasteReportModel.dart';
import 'package:wasteexpert/Config.url.dart' as UrlConfig;

class WasteReportController {
  final String wasteReportURL = UrlConfig.wasteReportUrl;
  final String getReportedWaste = UrlConfig.getwasteReportUrl;

  Future<void> reportWaste({
    required String userId,
    required File photo,
    required double locationLat,
    required double locationLng,
    required String reportDate,
    required String description,
    required List<String> wasteTypes,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(wasteReportURL));

    request.fields['UserId'] = userId;
    request.fields['locationLat'] = locationLat.toString();
    request.fields['locationLng'] = locationLng.toString();
    request.fields['ReportDate'] = reportDate;
    request.fields['Description'] = description;
    request.fields['WasteTypes'] = jsonEncode(wasteTypes);

    // Attach image file
    request.files.add(await http.MultipartFile.fromPath('Photo', photo.path,
        filename: basename(photo.path)));

    final response = await request.send();

    if (response.statusCode == 201) {
      print('Report successfully created');
    } else {
      print('Failed to create report: ${response.reasonPhrase}');
    }
  }

  Future<List<WasteReportModel>> getWasteReportsByUser(String userId) async {
    try {
      final response = await http.post(
        Uri.parse(getReportedWaste),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"UserId": userId}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['data'];

        // Check the structure
        print('Response data: $data');

        return data.map((report) => WasteReportModel.fromJson(report)).toList();
      } else {
        throw Exception('Failed to load waste reports');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
