import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class PositionController {
  static const String _positionKey = 'currentPosition';

  Future<void> saveCurrentPosition(Position position) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String positionString = jsonEncode({
      'lat': position.latitude,
      'lng': position.longitude,
    });
    await prefs.setString(_positionKey, positionString);
  }

  Future<Position?> getCurrentPositionFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? positionString = prefs.getString(_positionKey);

    if (positionString != null) {
      final Map<String, dynamic> positionJson = jsonDecode(positionString);
      return Position(
        latitude: positionJson['lat'],
        longitude: positionJson['lng'],
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        headingAccuracy: 0.0,
        altitudeAccuracy: 0.0,
      );
    }
    return null;
  }
}
