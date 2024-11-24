import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:wasteexpert/controllers/smartbin_controller.dart';
import 'package:wasteexpert/pages/ImageScan/ImageScan.dart';
import 'package:wasteexpert/pages/home.dart';
import 'package:wasteexpert/pages/location/bin_location_map.dart';
import 'package:wasteexpert/pages/notifications/notifications.dart';
import 'package:wasteexpert/pages/profile/Profile.dart';
import 'package:wasteexpert/pages/waste_reporting/report_waste.dart';
import 'package:wasteexpert/pages/waste_scheduling/schedule_waste.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  final String token; // Explicitly define the type
  const HomePage({required this.token, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _selectedIndex = 0;
  late String userName;
  late String userId;
  late String email;
  Position? _currentPosition;
  List<dynamic> _nearbyBins = []; // State to store nearby bins

  late File _imageFile;

  void _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      setState(() {
        _imageFile = File(imageFile.path); // Store the image file in state
      });
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ReportWaste(imageFile: _imageFile!, userId: userId)));
    } else {
      print('No image selected.');
    }
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        print('Notification permission granted');
      } else {
        print('Notification permission denied');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    Map<String, dynamic> jwtToken = JwtDecoder.decode(widget.token);
    userName = jwtToken['name'];
    userId = jwtToken['_id'];
    email = jwtToken['email'];

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showNotification(message.notification);
      }
    });
    // _checkPermissions();
  }

  void _showNotification(RemoteNotification? notification) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'notifications_channel_id', // Unique ID for the channel
        'Notifications', // Name of the channel
        channelDescription:
            'Channel for receiving notifications', // Description of the channel
        importance: Importance.max, // Importance level of notifications
        priority: Priority.high, // Priority level of notifications
        ticker: 'ticker', // Optional: Ticker text for the notification
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID (can be used to update or cancel the notification)
        notification?.title ?? 'No Title', // Notification title
        notification?.body ?? 'No Body', // Notification body
        platformChannelSpecifics, // Notification details for Android
        payload: 'item x',
        // Optional payload for extra data
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  late final List<Widget> _widgetOptions = <Widget>[
    Home(
        onRequestPickup: () =>
            _onItemTapped(3),
            userId: userId // Pass the nearby bins to the Home widget
        ),
    const BinMap(),
    const ImageScan(),
    ScheduleWaste(userId: userId, email: email),
    ProfileScreen(token: widget.token),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Future<void> _checkPermissions() async {
  //   PermissionStatus permission = await Permission.location.status;
  //   if (permission != PermissionStatus.granted) {
  //     PermissionStatus result = await Permission.location.request();
  //     if (result != PermissionStatus.granted) {
  //       // Handle permission denied
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Location permission is required')),
  //       );
  //       _showLocationServiceDialog();
  //     } else {
  //       _checkLocationService();
  //     }
  //   } else {
  //     _checkLocationService();
  //   }
  // }

  // Future<void> _checkLocationService() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     _showLocationServiceDialog();
  //   } else {
  //     _getCurrentLocation();
  //   }
  // }

  // Future<void> _showLocationServiceDialog() async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Enable Location Service'),
  //         content: const Text(
  //             'Location services are disabled. Please enable them to proceed.'),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.of(context).pop();
  //               await Geolocator.openLocationSettings();
  //             },
  //             child: const Text('Enable'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Future<void> _getCurrentLocation() async {
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     return;
  //   }

  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     _currentPosition = position;
  //   });
  //   _fetchNearbyBins(position.latitude, position.longitude,
  //       '3000'); // Fetch bins with a 10km radius
  // }

  // Future<void> _fetchNearbyBins(double lat, double lng, String radius) async {
  //   try {
  //     SmartBinController _binController = SmartBinController();
  //     // await _binController.getSmartBins(lat.toString(), lng.toString(), radius);
  //     setState(() async {
  //       _nearbyBins = await _binController.getSmartBins(
  //           lat.toString(), lng.toString(), radius) as List<dynamic>;
  //     });
  //   } catch (error) {
  //     print('Error: $error');
  //   }
  // }

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
              child: IconButton(
                onPressed: () => {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Notifications()))
                },
                icon: const Icon(Icons.notifications),
              ),
            ),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_openCamera()},
        backgroundColor: const Color.fromARGB(255, 23, 107, 135),
        child: const Icon(
          Icons.photo_camera_outlined,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 24,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            backgroundColor: Colors.white,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Bins',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 45, // Adjust size as needed
                  height: 45,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(
                        255, 23, 107, 135), // Set the background color to red
                    shape: BoxShape.circle, // Make the container rounded
                  ),
                ),
                const Icon(
                  Icons.photo_album_rounded,
                  color: Colors
                      .white, // Set icon color to contrast with background
                ),
              ],
            ),
            label: 'Find Bin',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Requests',
          ),
          const BottomNavigationBarItem(
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
