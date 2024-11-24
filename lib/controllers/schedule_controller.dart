import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wasteexpert/models/WasteSchedule/SchedulePickupModel.dart';
import 'package:wasteexpert/models/WasteSchedule/WasteScheduleModel.dart';
import 'package:wasteexpert/Config.url.dart' as UrlConfig;

class ScheduleController {
  final String apiUrl = UrlConfig.scheduleUrl;
  final String getscheduleUrl = UrlConfig.getscheduleUrl;
  final String updatescheduleUrl = UrlConfig.updatescheduledateUrl;
  final String deletescheduleUrl = UrlConfig.deletescheduledateUrl;
  final String getSchedulePickupDataUrl = UrlConfig.getSchedulePickupDataUrl;

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

  Future getscheduleWaste(String userId, String state) async {
    final response = await http.post(
      Uri.parse(getscheduleUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"UserId": userId, "ScheduleState": state}),
    );

    if (response.statusCode == 201) {
      // If the server returns a 201 CREATED response,
      // then parse the JSON.
      // print('Schedule successfully created: ${response.body}');
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create schedule: ${response.body}');
    }
  }

  Future updatescheduleDate(String scheduleId, String scheduleDate) async {
    final response = await http.post(
      Uri.parse(updatescheduleUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body:
          jsonEncode({"scheduleId": scheduleId, "scheduleDate": scheduleDate}),
    );

    if (response.statusCode == 201) {
      // If the server returns a 201 CREATED response,
      // then parse the JSON.
      // print('Schedule successfully created: ${response.body}');
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to update schedule: ${response.body}');
    }
  }

  Future deletescheduleData(String scheduleId) async {
    final response = await http.post(
      Uri.parse(deletescheduleUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"scheduleId": scheduleId}),
    );

    if (response.statusCode == 201) {
      // If the server returns a 201 CREATED response,
      // then parse the JSON.
      // print('Schedule successfully created: ${response.body}');
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to update schedule: ${response.body}');
    }
  }

  Future<List<SchedulePickup>> fetchUserSchedulePickups(String userId) async {
    final response = await http.post(
      Uri.parse(getSchedulePickupDataUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"userId": userId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      return (data['schedulePickups'] as List)
          .map((pickup) => SchedulePickup.fromJson(pickup))
          .toList();
    } else {
      throw Exception('Failed to load schedule pickups');
    }
  }
}
