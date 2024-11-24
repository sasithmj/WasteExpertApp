import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wasteexpert/controllers/smartbin_controller.dart';
import 'package:wasteexpert/models/WasteBin/SmartBin.dart';

class NearByBins extends StatefulWidget {
  const NearByBins({Key? key}) : super(key: key);

  @override
  State<NearByBins> createState() => _NearByBinsState();
}

class _NearByBinsState extends State<NearByBins> {
  int _selectedButtonIndex = -1;
  Position? _currentPosition;
  List<SmartBin> _nearbyBins = [];
  List<SmartBin> _filteredBins = [];
  bool _isLoading = true; // Initially, set to true to show loader

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    PermissionStatus permission = await Permission.location.status;
    if (permission != PermissionStatus.granted) {
      PermissionStatus result = await Permission.location.request();
      if (result != PermissionStatus.granted) {
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
    _fetchNearbyBins(position.latitude, position.longitude, '3000');
  }

  Future<void> _fetchNearbyBins(double lat, double lng, String radius) async {
    try {
      SmartBinController binController = SmartBinController();
      final bins = await binController.getSmartBins(
          lat.toString(), lng.toString(), radius);
      setState(() {
        _nearbyBins = bins;
        _filteredBins = bins; // Initially show all bins
        _isLoading = false; // Set to false when data is loaded
      });
    } catch (error) {
      print('Error: $error');
      setState(() {
        _isLoading = false; // Set to false on error as well
      });
    }
  }

  void _filterBins(String selectedType) {
    setState(() {
      _filteredBins = _nearbyBins
          .where((bin) => bin.garbageTypes.contains(selectedType))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = ["Food", "Plastic", "Paper", "Glass", "Metal"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            "NearBy Bins",
            style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ToggleButtons(
              isSelected: List.generate(
                  categories.length, (index) => index == _selectedButtonIndex),
              onPressed: (int index) {
                setState(() {
                  _selectedButtonIndex = index;
                  _filterBins(categories[index]);
                });
              },
              selectedColor: Colors.blue,
              color: const Color.fromARGB(255, 23, 107, 135),
              fillColor: Colors.blue.withOpacity(0.1),
              borderWidth: 0,
              children: categories.map((category) {
                return _buildButton(category);
              }).toList(),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Divider(),
        ),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _filteredBins.isNotEmpty
                ? Column(
                    children: _filteredBins.map((bin) {
                      return _binData(
                        bin.garbageTypes,
                        _getImagePath(bin.garbageTypes),
                        bin.area,
                        bin.area, // Assuming "area" as address placeholder
                        "bin location data",
                      );
                    }).toList(),
                  )
                : Center(
                    child: Text('No bins found'),
                  ),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildButton(String name) {
    String imagePath = _getImagePathByName(name);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 75,
            height: 100,
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  String _getImagePathByName(String name) {
    switch (name) {
      case "Food":
        return 'assets/foodbin.png';
      case "Plastic":
        return 'assets/plasticbin.png';
      case "Paper":
        return 'assets/paperbin.png';
      case "Glass":
        return 'assets/glassbin.png';
      case "Metal":
        return 'assets/metalbin.png';
      default:
        return 'assets/unknownbin.png';
    }
  }

  String _getImagePath(String garbageType) {
    if (garbageType.contains("Food")) {
      return 'assets/foodbin.png';
    } else if (garbageType.contains("Plastic")) {
      return 'assets/plasticbin.png';
    } else if (garbageType.contains("Paper")) {
      return 'assets/paperbin.png';
    } else if (garbageType.contains("Glass")) {
      return 'assets/glassbin.png';
    } else if (garbageType.contains("Metal")) {
      return 'assets/metalbin.png';
    } else {
      return 'assets/unknownbin.png';
    }
  }

  Widget _binData(String garbageType, String imagePath, String area,
      String address, String link) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 245, 245, 245),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 75,
              height: 100,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    address,
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.navigation_rounded,
                color: Colors.white, // Set icon color to white
              ),
              label: const Text(
                "Location",
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
              onPressed: () {
                // Handle navigation action here
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (states) {
                    return const Color.fromARGB(255, 23, 107,
                        135); // Color when button is enabled and disabled
                  },
                ),
                foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white), // Set text and icon color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
