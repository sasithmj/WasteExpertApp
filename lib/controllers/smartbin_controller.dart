// controllers/smart_bin_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:wasteexpert/models/WasteBin/SmartBin.dart';

import 'package:wasteexpert/Config.url.dart' as UrlConfig;

class SmartBinController {
  final String getSmartBindataUrl = UrlConfig.getSmartBindataUrl;
  final String getAllSmartBin = UrlConfig.getAllSmartBindataUrl;

  Future<List<SmartBin>> getSmartBins(
      String lat, String lng, String radius) async {
    final response = await http.post(
      Uri.parse(getSmartBindataUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"lat": lat, "lng": lng, "radius": radius}),
    );
    if (response.statusCode == 200) {
      var data = BinResponse.fromJson(jsonDecode(response.body));
      print(data.bins);
      return data.bins;
    } else {
      throw Exception('Failed to load bins');
    }
  }

  Future<List<SmartBin>> getAllSmartBins() async {
    final response = await http.post(
      Uri.parse(getAllSmartBin),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        List<SmartBin> bins = (data['smartbins'] as List)
            .map((bin) => SmartBin.fromJson(bin))
            .toList();
        return bins;
      } else {
        throw Exception('Failed to load smart bins');
      }
    } else {
      throw Exception('Failed to load smart bins');
    }
  }

  final Completer<GoogleMapController> _mapController = Completer();
  Completer<GoogleMapController> get mapController => _mapController;
}
