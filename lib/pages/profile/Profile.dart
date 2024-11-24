import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasteexpert/Config.url.dart' as UrlConfig;
import 'package:wasteexpert/controllers/user_controller.dart';
import 'package:wasteexpert/pages/Rewards/reward.dart';
import 'package:wasteexpert/pages/authentication/login.dart';
import 'package:wasteexpert/pages/profile/EditProfile.dart';
import 'package:wasteexpert/pages/profile/ManageLocation.dart';
import 'package:wasteexpert/pages/profile/Myshedules.dart';
import 'package:wasteexpert/pages/profile/ReportWasteDetails.dart';
import 'package:wasteexpert/widgets/profile/profile_menu.dart';

class ProfileScreen extends StatefulWidget {
  final String? token; // Make token nullable
  const ProfileScreen({@required this.token, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String userName;
  late String userId;
  late String email;
  bool isTokenValid = false;
  File? _image;
  List<int>? _profilePictureBase64;
  String? base64image;
  bool isimage = true;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      try {
        Map<String, dynamic> jwtToken = JwtDecoder.decode(widget.token!);
        if (jwtToken.containsKey('name') && jwtToken['name'] != null) {
          userName = jwtToken['name'];
          userId = jwtToken['_id'];
          email = jwtToken['email'];
          isTokenValid = true;
          _getUserdata(email);
        } else {
          // Handle missing 'name' field
          userName = 'Unknown User';
        }
      } catch (e) {
        // Handle token decoding error
        userName = 'Invalid Token';
      }
    } else {
      // Handle null token
      userName = 'No Token Provided';
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _updateProfilePicture(_image!);
    }
  }

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;
    final compressedImage = img.encodeJpg(image, quality: 50);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/compressed_image.jpg');
    await tempFile.writeAsBytes(compressedImage);

    return tempFile;
  }

  Future<void> _updateProfilePicture(File image) async {
    UserController _userController = UserController();
    try {
      await _userController.updateProfilePicture(email, image);
      // After updating, fetch user data again to refresh profile picture
      _getUserdata(email);
    } catch (e) {
      print('Failed to update profile picture: $e');
    }
  }

  Future<void> _getUserdata(String email) async {
    UserController userController = UserController();
    try {
      Map<String, dynamic>? userData = await userController.getUserData(email);

      // Check if the user data contains the profile picture URL
      if (userData?["user"]["profilepicture"] is String) {
        setState(() {
          base64image = userData?["user"]["profilepicture"];
        });
        print('Profile picture URL: $base64image');
      } else {
        // Handle case where profile picture is not provided or in an unexpected format
        print('Profile picture URL not found or invalid');
        setState(() {
          base64image = null; // Or provide a default URL or image
        });
      }
    } catch (e) {
      // Handle error
      print('Failed to fetch user data: $e');
      setState(() {
        base64image = null; // Ensure state is reset on error
      });
    }
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    // Navigate to the Login page and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (Route<dynamic> route) => false,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _logout(context); // Call the logout function
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// -- IMAGE
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: base64image != null && base64image!.isNotEmpty
                          ? _buildImage(base64image!) // Using network image now
                          : Image.network(
                              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8cHJvZmlsZSUyMHBpY3R1cmV8ZW58MHx8MHx8fDA%3D',
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: const Color.fromARGB(255, 23, 107, 135),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              // Text(
              //   userName,
              //   style: Theme.of(context).textTheme.headlineMedium,
              // ),
              const SizedBox(height: 20),

              /// -- BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(email: email),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 23, 107, 135),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("Edit Profile",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              /// -- MENU
              ProfileMenuWidget(
                  title: "My Schedules",
                  icon: Icons.calendar_month,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MySchedules()),
                    );
                  }),
              ProfileMenuWidget(
                  title: "Reported Waste",
                  icon: Icons.auto_delete_rounded,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReportWasteDetails()),
                    );
                  }),
              ProfileMenuWidget(
                  title: "Points",
                  icon: Icons.star,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RewardPage()),
                    );
                  }),
              const Divider(),
              // ProfileMenuWidget(
              //     title: "Settings", icon: Icons.settings, onPress: () {}),
              ProfileMenuWidget(
                  title: "Manage Location",
                  icon: Icons.pin_drop,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManageLocation(email: email)),
                    );
                  }),

              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                  title: "About Us", icon: Icons.info, onPress: () {}),
              ProfileMenuWidget(
                  title: "Logout",
                  icon: Icons.logout,
                  textColor: Colors.red,
                  endIcon: false,
                  onPress: () {
                    _showLogoutConfirmationDialog(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String photoPath) {
    final imageUrl = '${UrlConfig.url}$photoPath'; // Construct the image URL
    print(imageUrl);

    return Image.network(
      imageUrl,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image);
      },
    );
  }
}
