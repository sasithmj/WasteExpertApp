import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wasteexpert/models/WasteSchedule/WasteScheduleModel.dart';
import 'package:wasteexpert/Config.url.dart' as UrlConfig;

class ScheduleController {
  final String apiUrl = UrlConfig.scheduleUrl;

  Future<void> scheduleWaste(ScheduleData scheduleData) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(scheduleData.toJson()),
    );

    if (response.statusCode == 201) {
      // If the server returns a 201 CREATED response,
      // then parse the JSON.
      print('Schedule successfully created: ${response.body}');
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create schedule: ${response.body}');
    }
  }
}
