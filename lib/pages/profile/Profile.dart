import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:wasteexpert/pages/profile/ManageLocation.dart';
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
                      child: const Image(
                        image: NetworkImage(
                            "https://images.unsplash.com/flagged/photo-1595514191830-3e96a518989b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fG1hbGUlMjBwcm9maWxlfGVufDB8fDB8fHww"),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color.fromARGB(255, 23, 107, 135)),
                      child: const Icon(
                        Icons.add_a_photo,
                        color: Color.fromARGB(255, 255, 255, 255),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                userName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),

              /// -- BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to update profile screen
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 23, 107, 135),
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: const Text("Edit Profile",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              /// -- MENU
              ProfileMenuWidget(
                  title: "Points", icon: Icons.star, onPress: () {}),
              ProfileMenuWidget(
                  title: "Settings", icon: Icons.settings, onPress: () {}),
              ProfileMenuWidget(
                  title: "Manage Location", icon: Icons.pin_drop, onPress: () {
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
                    // Handle logout logic
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
