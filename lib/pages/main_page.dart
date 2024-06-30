import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:wasteexpert/pages/home.dart';
import 'package:wasteexpert/pages/profile/Profile.dart';
import 'package:wasteexpert/pages/waste_scheduling/schedule_waste.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  final String token; // Explicitly define the type
  const HomePage({required this.token, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late String userName;
  late String userId;
  late String email;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtToken = JwtDecoder.decode(widget.token);
    userName = jwtToken['name'];
    userId = jwtToken['_id'];
    email = jwtToken['email'];
    _checkPermissions();
  }

  late final List<Widget> _widgetOptions = <Widget>[
    Home(onRequestPickup: () => _onItemTapped(2)),
    Text('Index 1: Business'),
    ScheduleWaste(token: userId),
    Text('Index 2: School'),
    ProfileScreen(token: widget.token),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _checkPermissions() async {
    PermissionStatus permission = await Permission.location.status;
    if (permission != PermissionStatus.granted) {
      PermissionStatus result = await Permission.location.request();
      if (result != PermissionStatus.granted) {
        // Handle permission denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required')),
        );
        _showLocationServiceDialog();
      } else {
        _checkLocationService();
      }
    } else {
      _checkLocationService();
    }
  }

  Future<void> _checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _showLocationServiceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Location Service'),
          content: const Text(
              'Location services are disabled. Please enable them to proceed.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Enable'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
    print(_currentPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/horizontal_logo_light.png",
          height: 70,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        backgroundColor: const Color.fromARGB(255, 23, 107, 135),
        child: const Icon(
          Icons.photo_camera_outlined,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 24,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Bins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 23, 107, 135),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.shifting, // Shifting
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
