import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wasteexpert/controllers/smartbin_controller.dart';
import 'package:wasteexpert/models/WasteBin/SmartBin.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class SmartBinMap extends StatefulWidget {
  final List<String> wasteCategories;

  const SmartBinMap({Key? key, required this.wasteCategories})
      : super(key: key);

  @override
  State<SmartBinMap> createState() => _SmartBinMapState();
}

class _SmartBinMapState extends State<SmartBinMap> {
  final SmartBinController _controller = SmartBinController();
  List<Marker> _markers = [];
  late GoogleMapController _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  List<SmartBin> _nearbyBins = [];
  List<SmartBin> _filteredBins = [];
  int _selectedButtonIndex = -1;

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
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
    _fetchNearbyBins(position.latitude, position.longitude, '3000');
  }

  Future<void> _fetchNearbyBins(double lat, double lng, String radius) async {
    try {
      final bins = await _controller.getSmartBins(
          lat.toString(), lng.toString(), radius);
      setState(() {
        _nearbyBins = bins;
        _filteredBins = bins
            .where((bin) => widget.wasteCategories.contains(bin.garbageTypes))
            .toList();
        _isLoading = false;
      });
      _loadMarkers();
    } catch (error) {
      print('Error: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMarkers() async {
    final List<Marker> markerList = [];
    for (var bin in _filteredBins) {
      final markerIcon = await _getMarkerIconByName(bin.garbageTypes);
      final marker = Marker(
        markerId: MarkerId(bin.id),
        position: LatLng(bin.locationLat, bin.locationLng),
        icon: markerIcon,
        infoWindow: InfoWindow(
          title: bin.garbageTypes,
          snippet: 'Fill Level: ${bin.fillLevel}',
        ),
        onTap: () => _showBinDetails(bin),
      );
      markerList.add(marker);
    }
    setState(() {
      _markers = markerList;
    });
  }

  Future<BitmapDescriptor> _getMarkerIconByName(String name) async {
    String imagePath = _getImagePathByName(name);
    final ByteData bytes = await rootBundle.load(imagePath);
    final Uint8List list = bytes.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(list,
        targetWidth: 96, targetHeight: 110);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedBytes =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(resizedBytes!.buffer.asUint8List());
  }

  String _getImagePathByName(String name) {
    if (name.contains("Food")) return 'assets/foodbin.png';
    if (name.contains("Plastic")) return 'assets/plasticbin.png';
    if (name.contains("Paper")) return 'assets/paperbin.png';
    if (name.contains("Glass")) return 'assets/glassbin.png';
    if (name.contains("Metal")) return 'assets/metalbin.png';
    return 'assets/unknownbin.png';
  }

  void _showBinDetails(SmartBin bin) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${bin.garbageTypes} Bin",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Area: ${bin.area}'),
              Text('Fill Level: ${bin.fillLevel}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Implement navigation to the bin
                },
                child: const Text("Get Directions"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _filterBins(String selectedType) {
    setState(() {
      _filteredBins = _nearbyBins
          .where((bin) => bin.garbageTypes.contains(selectedType))
          .toList();
      _loadMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                    zoom: 14,
                  ),
                  markers: Set<Marker>.of(_markers),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                ),
                Positioned(
                  bottom: 40,
                  left: 10,
                  right: 10,
                  child: _buildFilterButtons(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            widget.wasteCategories.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedButtonIndex = index;
                    _filterBins(widget.wasteCategories[index]);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedButtonIndex == index
                      ? Colors.blue
                      : Colors.grey[300],
                ),
                child: Text(widget.wasteCategories[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
