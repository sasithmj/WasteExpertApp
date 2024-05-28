// home_page.dart
import 'package:flutter/material.dart';
import 'package:wasteexpert/pages/home.dart';
import 'package:wasteexpert/pages/waste_scheduling/schedule_waste.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions = <Widget>[
    Home(
        onRequestPickup: () => _onItemTapped(2)), // Change to the desired index
    Text('Index 1: Business'),
    SheduleWaste(),
    Text('Index 2: School'),
    Text('Index 4: Profiles'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/horizontal_logo_light.png",
          height: 70,
        ),
      ),
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        backgroundColor: Color.fromARGB(255, 23, 107, 135),
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
        selectedItemColor: Color.fromARGB(255, 23, 107, 135),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.shifting, // Shifting
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: TextStyle(color: Colors.grey),
      ),
    );
  }
}
