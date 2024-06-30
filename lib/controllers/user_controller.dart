import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wasteexpert/Config.url.dart' as UrlConfig;

class UserController {
  final String locationUpdateUrl =
      UrlConfig.updateLocationUrl; // Update with the correct URL
  final String getUserUrl = UrlConfig.updateLocationUrl;
  final String getuserDetails = UrlConfig.getUserDetailsUrl;
  final String addressUpdateUrl = UrlConfig.updateAddressUrl;

  Future<void> updateLocation(String email, double lat, double lng) async {
    final url = Uri.parse(locationUpdateUrl);

    final Map<String, dynamic> data = {
      'email': email,
      'lat': lat,
      'lng': lng,
    };
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Location updated successfully');
      } else {
        print('Failed to update location: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating location: $error');
    }
  }

  Future<void> updateAddress(String email, String street, String city,
      String state, String zip) async {
    final url = Uri.parse(addressUpdateUrl);

    final Map<String, dynamic> data = {
      'email': email,
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
    };
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Address updated successfully');
      } else {
        print('Failed to update Address: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating Address: $error');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String email) async {
    final url = Uri.parse(getuserDetails);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('User data retrieved successfully');
        return data;
      } else {
        print('Failed to retrieve user data: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error retrieving user data: $error');
      return null;
    }
  }
}
