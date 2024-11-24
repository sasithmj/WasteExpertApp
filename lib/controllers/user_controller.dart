import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasteexpert/Config.url.dart' as UrlConfig;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class UserController {
  final String locationUpdateUrl =
      UrlConfig.updateLocationUrl; // Update with the correct URL
  final String getUserUrl = UrlConfig.updateLocationUrl;
  final String getuserDetails = UrlConfig.getUserDetailsUrl;
  final String addressUpdateUrl = UrlConfig.updateAddressUrl;
  final String updateProfileUrl = UrlConfig.updateProfileUrl;

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
      String state, String zip, double latitude, double longitude) async {
    final url = Uri.parse(addressUpdateUrl);

    final Map<String, dynamic> data = {
      'email': email,
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
      'latitude': latitude,
      'longitude': longitude,
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

  Future<String?> getUserIdFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token != null) {
      Map<String, dynamic> jwtToken = JwtDecoder.decode(token);
      return jwtToken['_id'];
    }
    return null;
  }

  Future<void> updateProfilePicture(String email, File image) async {
    const String uploadUrl = UrlConfig.updateProfilePictureUrl;

    // Validation: Check if the file exists
    if (!image.existsSync()) {
      print('Error: Image file does not exist.');
      return;
    }

    // Validation: Check if the file size is within the acceptable range (e.g., max 5MB)
    final int fileSize = await image.length();
    const int maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    if (fileSize > maxSizeInBytes) {
      print('Error: Image file is too large. Maximum allowed size is 5MB.');
      return;
    }

    // Validation: Check if the file is of the expected image type (e.g., JPEG, PNG)
    final String? mimeType = lookupMimeType(image.path);
    if (mimeType == null ||
        !(mimeType.startsWith('image/jpeg') ||
            mimeType.startsWith('image/png'))) {
      print('Error: Invalid image type. Only JPEG and PNG are allowed.');
      return;
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['email'] = email;

      request.files.add(await http.MultipartFile.fromPath(
          'profilepicture', image.path,
          filename: basename(image.path)));

      final response = await request.send();

      // Validation: Check the response status code
      if (response.statusCode == 200) {
        print('Profile picture updated successfully');
      } else if (response.statusCode == 401) {
        print(
            'Failed to update profile picture: Unauthorized access. Please check your credentials.');
      } else if (response.statusCode == 413) {
        print(
            'Failed to update profile picture: Payload too large. Please upload a smaller image.');
      } else {
        print('Failed to update profile picture: ${response.statusCode}');
      }
    } catch (e) {
      // Validation: Catch and print any exceptions that occur during the request
      print('Error updating profile picture: $e');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    // Add this URL to your Config.url.dart file
    final url = Uri.parse(updateProfileUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          ...userData,
        }),
      );

      if (response.statusCode == 200) {
        print('Profile updated successfully');
      } else {
        print('Failed to update profile: ${response.statusCode}');
        throw Exception('Failed to update profile');
      }
    } catch (error) {
      print('Error updating profile: $error');
      throw error;
    }
  }
}
